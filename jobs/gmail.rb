require 'gmail'
# # :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|
  items = []
  for i in 1..ENV['gmail_accounts'].to_i do
    gmail = Gmail.connect(ENV["gmail_username_#{i}"], ENV["gmail_password_#{i}"]) do |gmail|
      items << { label: ENV["gmail_name_#{i}"], value: gmail.inbox.count(:unread) }
    end
  end
  send_event('gmail', {items: items})
end
