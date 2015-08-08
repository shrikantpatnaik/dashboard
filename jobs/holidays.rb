require 'net/http'
require 'icalendar'

def get_cal
  uri = URI(ENV['holidays_cal_url'])
  cal_file = Net::HTTP.get(uri)
  cals = Icalendar.parse(cal_file)
  return cals.first
end


cal = get_cal

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '30s', :first_in => 0 do |job|
  # Re-Get calendar if values are stale
  if Date.parse(cal.events.last.dtstart.to_s, '%Y-%m-%d') < Date.today
    cal = get_cal()
  end
  finding_next = true
  nextHoliday = {}
  cal.events.each do |event|
      if finding_next and Date.parse(event.dtstart.to_s, '%Y-%m-%d') > Date.today
          finding_next = false
          nextHoliday = event
      end
  end
  summary = nextHoliday.summary.force_encoding("utf-8")
  noOfDays =   Date.parse(nextHoliday.dtstart.to_s,'%Y-%m-%d').mjd - Date.today.mjd
  send_event('holidays', {days: noOfDays.to_i, summary: summary })
end
