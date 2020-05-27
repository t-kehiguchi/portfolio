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

# モルモット第二号以降
for i in 1..50
  User.create!(employee_number:       22222222+i,
               password:              "password",
               password_confirmation: "password",
               name:                  "社員"+i.to_s,
               department:            "研修生",
               birthday:              "1988-05-08",
               nearest_station:       "新宿駅",
               telephone_number:      "090-1234-5678",
               join_able_date:        "2020-04-01")
end

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

## Project、Project_must_skills、Project_want_skills、Project_memberテーブルの登録
def createProjectAndSkillsAndMember()
  mustSkill = []
  wantSkill = []
  ## 1～30のスキルから抽出
  skillList = Skill.where("skill_id BETWEEN ? AND ?", 1, 30).pluck(:skill_id)
  ## 0～50件
  for i in 0..Random.new.rand(0..50)
    Project.create!(project_id:    Date.today.strftime("%Y%m%d") + format("-%02d", i+1),
                    project_name:  "A",
                    content:       "B",
                    environment:   "C",
                    price_min:     400000,
                    price_max:     500000,
                    min:           140,
                    max:           180,
                    start_date:    "2020-04-01",
                    end_date:      nil,
                    start_time:    "09:00",
                    end_time:      "18:00",
                    working_place: "品川",
                    description:   "D")

    project_id = Project.where("project_id LIKE ?", "%"+format("%02d", i+1)).order(project_id: "DESC").pluck(:project_id).first

    ## 必須スキルの数
    skillNum = Random.new.rand(1..3)

    for j in 0..skillNum-1
      flag = false
      ## 1～30のすでにあるスキルID以外の値を取得するまでループ
      while !flag
        skill_id = skillList[Random.new.rand(0..skillList.count-1)]
        if mustSkill.empty? or !mustSkill.include?(skill_id)
          mustSkill[j] = skill_id
          flag = true
        end
      end

      ProjectMustSkill.create!(project_id:    project_id,
                               must_skill_id: mustSkill[j])
    end

    ## 尚可スキル付与可否
    wantSkillFlag = Random.new.rand(0..1).to_s

    ## 尚可スキルは任意
    if wantSkillFlag
      ## 必須スキルの数
      wantSkillNum = Random.new.rand(1..3)
      for k in 0..wantSkillNum-1
        flag = false
        ## 1～30のすでにあるスキルID以外の値を取得するまでループ
        while !flag
          skill_id = skillList[Random.new.rand(0..skillList.count-1)]
          if wantSkill.empty? or !wantSkill.include?(skill_id)
            wantSkill[k] = skill_id
            flag = true
          end
        end
        ProjectWantSkill.create!(project_id:    project_id,
                                 want_skill_id: wantSkill[k])
      end
    end
  end

  ## 参画メンバー(デフォルトで第一号(11111111)だけ)
  ## 対象のプロジェクトを無作為抽出
  project = Project.order("Rand()").limit(1)
  ## 1件しかないがActiveRecord的にeachで回す
  project.each do |p|
    ProjectMember.create!(project_id:      p.project_id,
                          employee_number: 11111111,
                          start_date:      Date.today.strftime("%Y-%m-%d"),
                          end_date:        nil)
  end

end

# Project Project_must_skills Project_want_skills、Project_member
createProjectAndSkillsAndMember()
