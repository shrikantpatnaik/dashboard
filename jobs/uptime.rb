require 'uptimerobot'
require 'yaml'

config = YAML.load_file("config.yml")

client = UptimeRobot::Client.new(apiKey: config["uptime_robot"]["api_key"])

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|
  response = client.getMonitors({responseTimes: 1, responseTimesAverage: 3600, customUptimeRatio: 1})
  monitors = []
  response['monitors']['monitor'].each do |monitor|
    thisMonitor = {}
    monitors << {
      name: monitor['friendlyname'],
      uptime: monitor['customuptimeratio'],
      response_time: monitor['responsetime'].nil? ? "?" : monitor['responsetime'].first['value'],
      status: monitor['status'],
    }
  end
  send_event('uptime-robot', { items: monitors})
end
