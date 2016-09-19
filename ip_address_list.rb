
# グローバルアドレスの取得
# プライベートアドレス空間
## クラスA：10.0.0.0 - 10.255.255.255
## クラスB×16：172.16.0.0 - 172.31.255.255
## クラスC×256：192.168.0.0 - 192.168.255.25
range=0..255
range.each {|i|
  # プライベートアドレス（クラスA）を除外
  if i == 10 then
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
        #puts "#{i}.#{j}.#{k}.#{l}"
      }
    }
  }
}
