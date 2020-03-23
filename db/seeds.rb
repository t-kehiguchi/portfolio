# 代表
User.create!(employee_number:       99999999,
             password:              "password",
             password_confirmation: "password",
             name:                  "代表",
             department:            "代表取締役",
             birthday:              "1986-08-08",
             nearest_station:       "東京駅",
             telephone_number:      "012-3456-7890",
             join_able_date:        nil,
             admin_flag:            User.admins['admin'])

# 第一号
User.create!(employee_number:       11111111,
             password:              "password",
             password_confirmation: "password",
             name:                  "樋口健児",
             department:            "システム開発",
             birthday:              "1988-05-08",
             nearest_station:       "練馬駅",
             telephone_number:      "090-5496-0563",
             join_able_date:        "2020-04-01")

# モルモット第一号
User.create!(employee_number:       22222222,
             password:              "password",
             password_confirmation: "password",
             name:                  "新人",
             department:            "研修生",
             birthday:              "1989-05-25",
             nearest_station:       "谷在家駅",
             telephone_number:      "080-1307-4468",
             join_able_date:        "2020-04-01")

# スキルマスタ
skill = ["Windows", "Linux", "Java", "PHP", "Ruby", "C言語", "C#", "Python",
         "SQL", "HTML", "HTML5", "CSS", "CSS3", "JavaScript", "jQuery",
         "Node.js", "Vue.js", "ActionScript", "Ruby on Rails", "Spring",
         "Spring Boot", "Struts", "thymeleaf", "Oracle", "MySQL", "PostgresSQL",
         "Eclipse", "Intellij", "Cloud9", "Visual Studio"]
other = ["その他(OS)", "その他(言語)", "その他(フレームワーク)",
         "その他(DB)", "その他(ツール)", "その他"]
max   = 100
for i in 1..skill.count
  Skill.create!(id:         i,
                skill_name: skill[i-1])
end
for j in 1..other.count
  Skill.create!(id:         max-other.count+j,
                skill_name: other[j-1])
end

# 社員番号と保持したいスキルの数でpossessed_skillテーブルに登録する関数
def createPossessedSkill(employee_number, num)
  mySkill = []
  ## 1～30のスキルから抽出
  skillList = Skill.where("skill_id BETWEEN ? AND ?", 1, 30).pluck(:skill_id)
  if num > 0
    for i in 0..num-1
      flag = false
      ## 1～30のすでにあるスキルID以外の値を取得するまでループ
      while !flag
        skill_id = skillList[Random.new.rand(0..skillList.count-1)]
        if mySkill.empty? or !mySkill.include?(skill_id)
          mySkill[i] = skill_id
          flag = true
        end
      end
      PossessedSkill.create!(employee_number: employee_number,
                             skill_id:        mySkill[i],
                             month:           Random.new.rand(1..50))
    end
  end
end

# 第一号
createPossessedSkill(11111111, 5)
# モルモット第一号
createPossessedSkill(22222222, 0)