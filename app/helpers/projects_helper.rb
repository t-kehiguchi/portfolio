module ProjectsHelper

  ## 単価を金額表示(3桁区切り)にするメソッド
  def getPriceDisplay(price)
    return price.present? ? price.to_s(:delimited).concat("円") : ""
  end

  ## スキルIDからスキル名を取得するメソッド
  def getSkillName(skill_id)
    return Skill.find_by(skill_id: skill_id).skill_name
  end

  ## 社員番号からユーザー情報を取得するメソッド
  def getUser(employee_number)
    return User.find(employee_number)
  end

  ## 金額の幅を表示するメソッド
  def getPriceDsp
    price = {}
    ## 一旦400000円～1000000円
    for i in 4..10
      if i == 4
        price["<= "+(i*100000).to_s] = "～ "+(i*100000).to_s(:delimited).concat("円")
      elsif i == 10
        price["BETWEEN "+((i-1)*100000).to_s+" AND "+(i*100000).to_s] = ((i-1)*100000).to_s(:delimited).concat("円 ～ ")+(i*100000).to_s(:delimited).concat("円")
        price[">= "+(i*100000).to_s] = (i*100000).to_s(:delimited).concat("円 ～")
      else
        price["BETWEEN "+((i-1)*100000).to_s+" AND "+(i*100000).to_s] = ((i-1)*100000).to_s(:delimited).concat("円 ～ ")+(i*100000).to_s(:delimited).concat("円")
      end
    end
    return price
  end

  ## 月プルダウンを取得するためのMap
  def getMonthMap
    hash = {}
    ## 1月～12月まで取得
    for month in 1..12
      hash[month] = month
    end
    return hash
  end

  ## 日プルダウンを取得するためのMap
  def getDayMap
    hash = {}
    ## 1日～31日まで取得
    for day in 1..31
      hash[day] = day
    end
    return hash
  end

  ## 時(hour)プルダウンを取得するためのMap
  def getHourMap
    hash = {}
    ## 0時～23時まで取得
    for hour in 0..23
      hash[hour] = hour
    end
    return hash
  end

  ## 分(minutes)プルダウンを取得するためのMap
  def getMinutesMap
    hash = {}
    ## 0分～59分まで15分刻みで取得
    for minutes in 0..59
      if minutes % 15 == 0
        hash[minutes] = format("%02d", minutes)
      end
    end
    return hash
  end

  ## 2項目(時間)から～番目を指定して取得する
  ## 例 getTwo("05:08", 'second') → "08"
  def getTwo(value, number)
    ## 空は対象外
    if value.present?
      value = value.split(":")
      ## 分割(split)されなかった場合はnilを返す
      return nil if value.size <= 1
      ## numberが「first」の場合は1番目、「second」の場合は2番目、それ以外はnilを返す
      return number == 'first' ? value[0].to_i : number == 'second' ? value[1].to_i : nil
    end
  end

  ## 3項目(年月日や電話番号)から～番目を指定して取得する
  ## 例 getThree("1988-05-08", 'second') → "05"
  def getThree(value, number)
    ## 空は対象外
    if value.present?
      value = value.split("-")
      ## 分割(split)されなかった場合はnilを返す
      return nil if value.size <= 1
      ## numberが「first」の場合は1番目、「second」の場合は2番目、「third」の場合は3番目、それ以外はnilを返す
      return number == 'first' ? value[0] : number == 'second' ? value[1] : number == 'third' ? value[2] : nil
    end
  end

end
