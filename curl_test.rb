require 'curb'

url = '202.26.158.109'
h = Curl::Easy.new(url)
h.set :nobody, true
h.perform
puts h.header_str

=begin
res = Curl.header_str("#{url}") do |res|
  res.enable_cookies = true
  res.cookiefile = File.join(File.dirname(__FILE__), "cookies")
  res.cookiejar = File.join(File.dirname(__FILE__), "cookies")
end
puts res.header_str
=end
