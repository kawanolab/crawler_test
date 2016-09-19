require 'date'
require 'rubygems'
require 'whois'

c = Whois::Client.new(:timeout => 3)
#address = "tuis.ac.jp"
#address = "216.58.221.174"
address = "202.26.158.109"
filename = "whois.txt"
ans = c.lookup(address)

#r = Whois.whois(address)
#p = r.parser
#puts p

File.open(filename, 'w') do |file|
  file.puts ans
  puts ans
end

assigned_date = ""
File.open(filename, "r") do |file|
  file.each_line do |line|
    if line =~ /Assigned Date/
      # 登録日の取得
      assigned_date = Date.strptime(line.split[2], '%Y/%m/%d')
      puts "Assign: #{assigned_date}"

      # 本日までの経過日を計算
      today = Date.today
      puts "Today: #{today}"
      total_days = today - assigned_date
      years = total_days.div(365)
      days = total_days.modulo(365)
      puts "TotalDays: #{total_days} -> #{years} years #{days} days."
      puts "Over 1 year" if total_days >= 365

    end
  end
end

puts "Create: #{ans.created_on}"
puts "Update: #{ans.updated_on}"
puts "Expire: #{ans.expires_on}"


#created_on = "#{ans.created_on} (#{ans.created_on.to_remaining_str})"
#updated_on = (ans.updated_on.nil?) ? "N/A" : "#{ans.updated_on} (#{ans.updated_on.to_remaining_str})"
#expires_on = (ans.expires_on.nil?) ? "N/A" : "#{ans.expires_on} (#{ans.expires_on.to_remaining_str})"
#registrar  = (ans.registrar.nil?)  ? "N/A" : ans.registrar.name

#puts "created_on: #{created_on}"
#puts "updated_on: #{updated_on}"
#puts "expires_on: #{expires_on}"
#puts "registrar:  #{registrar}"

if ans.created_on.nil?
  puts "#{address} not registered or cannot get the created_on field."
else
  #puts "#{r.assigned_date}"


  today = Time.now
  total_days = ((today - ans.created_on) / (24*60*60)).to_i
  years = total_days.div(365)
  days = total_days.modulo(365)
  puts "Today: #{today}"
  puts "TotalDays: #{total_days} -> #{years} years #{days} days."
end
