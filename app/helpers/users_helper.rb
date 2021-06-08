module UsersHelper

  ## 年プルダウンを取得するためのMap
  def getYearMap
    hash = {}
    ## 1950年～現在年まで取得
    for year in 1950..Date.today.year.to_i
      hash[year] = year
    end
    return hash
  end

  ## 経験年プルダウンを取得するためのMap
  def getExpYearMap
    hash = {}
    ## 30年まで取得
    for year in 0..30
      hash[year] = year
    end
    return hash
  end

  ## 参画可能日の年プルダウンを取得するためのMap
  def getJoinYearMap
    hash = {}
    ## 現在年～5年分まで取得
    now = Date.today.year
    for year in now..(now+5-1)
      hash[year] = year
    end
    return hash
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

  ## 経験月プルダウンを取得するためのMap
  def getExpMonthMap
    hash = {}
    ## 0ヶ月～11ヶ月まで取得
    for month in 0..11
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

  ## 誕生日から実年齢を取得するメソッド
  def getAge(birthday)
    today = Date.today.to_time.strftime('%Y%m%d').to_i
    birth = birthday.to_time.strftime('%Y%m%d').to_i
    return ((today - birth)/10000).to_i
  end

  ## 経験年数から経験月数を取得するメソッド(例. 5年8ヶ月 → 68ヶ月)
  def getTotalMonth(year, month)
    return year * 12 + month
  end

  ## 経験月数から経験年数を取得し表示するメソッド(例. 85ヶ月 → 7年1ヶ月)
  def getYearAndMonth(totalMonth)
    year = totalMonth / 12
    month = totalMonth - year * 12
    return year == 0 ? month.to_s + "ヶ月" : year.to_s + "年" + month.to_s + "ヶ月"
  end

  ## 経験月数から経験年数を取得し配列形式で返すメソッド(例. 85ヶ月 → [7, 1])
  def getYearAndMonthArray(totalMonth)
    year = totalMonth / 12
    month = totalMonth - year * 12
    return year, month
  end

  ## スキルIDからスキル名を取得するメソッド
  def getSkillName(skill_id)
    return Skill.find_by(skill_id: skill_id).skill_name
  end

  ## 保持スキルがあるか否かのCSS(display,disabled)を返す
  def isPossessedSkills(possessedSkills)
    if possessedSkills.present?
      return "display:none;", nil
    else
      return nil, "disabled=disabled"
    end
  end

  ## 最も経歴の長いスキル(ID)を取得するメソッド(スキルある人だけ)
  def getMostExperientedSkillId(employee_number)
    possessedSkill = PossessedSkill.where(employee_number: employee_number)
    return possessedSkill.present? ? possessedSkill.map {|ps| [ps.skill_id, ps.month]}.max {|x,y| x[1]<=>y[1]}[0] : nil
  end

end