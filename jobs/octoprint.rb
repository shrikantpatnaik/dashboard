require 'faraday'
require 'json'
require 'yaml'

config = YAML.load_file("config.yml")

conn = Faraday.new(:url => config['octoprint']['url']) do |faraday|
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

SCHEDULER.every '30s', :first_in => 0 do |job|
  resp = conn.get do |req|
    req.url '/api/job'
    req.headers['Content-Type'] = 'application/json'
    req.headers['X-Api-Key'] = config['octoprint']['api_key']
  end
  parsed_response = JSON.parse(resp.body)
  data = {
    progress:  "#{(parsed_response['progress']['completion'] * 100).round.to_f/100}%",
    state: parsed_response['state'],
    job: parsed_response['job']['file']['name']
  }
  send_event('octoprint', data)
end
