require 'curb'
require 'date'
require 'rubygems'
require 'whois'
require 'timeout'

# Whois情報の取得メソッド
def get_whois(address)
  c = Whois::Client.new(:timeout => 3)
  filename = "whois.txt"
  ans = c.lookup(address)
  File.open(filename, 'w') do |file|
    file.puts ans
    puts ans
  end

  elapsed_date = ""
  File.open(filename, "r") do |file|
    file.each_line do |line|
      if line =~ /Assigned Date/
        # 登録日の取得
        elapsed_date = Date.strptime(line.split[2], '%Y/%m/%d')
        puts "Assign: #{elapsed_date}"
      elsif line =~ /created/
        # 登録日の取得
        #puts "#{line}"
        line2 = line.split(":")[1][8, 17]
        #puts line2
        elapsed_date = Date.strptime(line2, '%Y-%m-%d')
        puts "Create: #{created_date}"
      else
        #puts "Less than 1 year"
        #return -1
        elapsed_date = @today
      end

      # 本日までの経過日を計算
      total_days = (@today - elapsed_date).to_i
      years = total_days.div(365)
      days = total_days.modulo(365)
      puts "TotalDays: #{total_days.to_i} -> #{years} years #{days} days."
      #puts "Over 1 year" if total_days >= 365
      return total_days

    end
  end

=begin
  if res.created_on.nil?
    puts "#{address} not registered or cannot get the created_on field."
    return -1
  else
    # Whois登録日時の表示
    puts "Create: #{r.created_on}"
    puts "Update: #{r.updated_on}"
    puts "Expire: #{r.expires_on}"

    total_days = ((@today - r.created_on) / (24*60*60)).to_i
    years = total_days.div(365)
    days = total_days.modulo(365)
    puts "Today: #{today}"
    puts "TotalDays: #{total_days} -> #{years} years #{days} days."
    return total_days
  end
=end
end

# HTTPヘッダの取得メソッド
def get_http_header(address)
  h = Curl::Easy.new(address)
  #h.connect_timeout = 3
  h.set :nobody, true
  begin
    Timeout.timeout(2) do
      h.perform
    end
  rescue Timeout::Error
    puts "Timeout #{address}"
  rescue Exception => e
    puts "Can't connect #{address}"
    return
  end
  puts h.header_str
  h.close
end


# グローバルアドレスの取得
# プライベートアドレス空間
## クラスA：10.0.0.0 - 10.255.255.255
## クラスB×16：172.16.0.0 - 172.31.255.255
## クラスC×256：192.168.0.0 - 192.168.255.25
range=0..255 # IPアドレスの取りうる範囲
whois_th=3650 # whois検索のしきい値
#@today = Time.now
@today = Date.today

range.each {|i|
  # プライベートアドレス（クラスA）を除外
  if i == 0 or i==1 or i == 10 then #i.between?(0,201) then
    #puts "#{i}.0.0.0/8"
    next
  end
  range.each {|j|
    # プライベートアドレス（クラスB）を除外
    if i == 172 and j.between?(16, 31) then
      #puts "#{i}.#{j}.0.0/12"
      next
    end

    # プライベートアドレス（クラスC）を除外
    if i == 192 and j == 168 then
      #puts "#{i}.#{j}.0.0/16"
      next
    end

    range.each {|k|
      range.each {|l|
        # ブロードキャストアドレスを除外
        if l == 255 then
          next
        # ループバックアドレスを除外
        elsif i == 127 and j == 0 and k == 0 and l == 1
          next
        end

        # グローバルアドレス
        address = "#{i}.#{j}.#{k}.#{l}"
        puts address

        # Whois情報の取得（365日以上なら次を実行）
        whois_days = get_whois(address)
        puts "Whois: #{whois_days}"
        if whois_days >= whois_th
          puts "Over 1 year; Skip"
          next
        end

        # HTTPヘッダの取得
        get_http_header(address)
        sleep(1)
      }
    }
  }
}
