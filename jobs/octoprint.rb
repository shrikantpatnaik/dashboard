require 'faraday'
require 'json'

conn = Faraday.new(:url => "http://#{ENV['octoprint_url']}") do |faraday|
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

SCHEDULER.every '30s', :first_in => 0 do |job|
  resp = conn.get do |req|
    req.url '/api/job'
    req.headers['Content-Type'] = 'application/json'
    req.headers['X-Api-Key'] = ENV['octoprint_api_key']
  end
  parsed_response = JSON.parse(resp.body)
  print_time = parsed_response['progress']['printTimeLeft']
  time_left = if !print_time.nil? and print_time.is_a? Integer
    Time.at(print_time).utc.strftime("%H:%M:%S")
  else
    "unknown"
  end
  filename = parsed_response['job']['file']['name']
  filename.slice! ".gcode"
  if filename.size > 17
    filename = filename[0..16] + ".."
  end

  progress = if parsed_response['progress']['completion'].nil?
      "unknown"
    else
      (parsed_response['progress']['completion'] * 100).round.to_f/100
    end
  data = {
    progress:  "#{progress}%",
    state: parsed_response['state'],
    job: filename,
    time_left: time_left
  }
  send_event('octoprint', data)
end
