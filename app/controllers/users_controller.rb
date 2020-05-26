class UsersController < ApplicationController

  ## 検索結果
  @@result = []

  def new
    invalidUrl()
    if request.post?
      flag = true
      ## エンジニア情報
      @user = User.new(user_params)
      unless @user.save
        flag = false
      end
      ## 保有スキル情報
      ## 保有スキルが設定されている場合
      if params[:possessedSkill]
        params[:possessedSkill].values.each do |s|
          ## 経験年数が0ヶ月(以下)の場合は未経験とみなし対象外
          if s["month"].to_i > 0
            ## StrongParameter使えないため1レコードずつinsert
            @possessedSkill = PossessedSkill.new(employee_number: s["employee_number"],
                                                 skill_id: s["skill_id"],
                                                 month: s["month"])
            unless @possessedSkill.save
              flag = false
            end
          else
            flash[:danger] = 'スキル「' + getSkillName(s["skill_id"]) + '」は未経験扱いとなるので登録しませんでした。'
          end
        end
      end
      if flag
        flash[:success] = @user.name + 'さん作成しました。'
        redirect_to root_url
      end
    else
      @skills = Skill.all
      @employee_number = getRandomEmployeeNumber
    end
  end

  def edit
    if request.post?
      flag = true
      @user = User.find(params["user"]["employee_number"])
      unless @user.update_attributes(user_params)
        flag = false
      end
      ## 保有スキル情報
      ## 現時点での保持スキル(skill_id)を取得(比較しやすいように昇順)
      possessedSkillsNow = PossessedSkill.where(employee_number: params["user"]["employee_number"]).pluck(:skill_id).sort
      ## パラメータ側(skill_idの昇順)
      skill_id_list = []
      if params[:possessedSkill]
        params[:possessedSkill].values.map { |possessedSkill|
          skill_id_list.push(possessedSkill["skill_id"].to_i).sort!
        }
      end
      ## 差分の配列
      diff = [skill_id_list - possessedSkillsNow, possessedSkillsNow - skill_id_list]
      if possessedSkillsNow.size < skill_id_list.size
        ## possessedSkillsNowにはなくskill_id_listにある場合 → insert
        if diff[0].present?
          params[:possessedSkill].values.map { |insert|
            if diff[0].include?(insert["skill_id"].to_i)
              ## 経験年数が0ヶ月(以下)の場合は未経験とみなし対象外
              if insert["month"].to_i > 0
                ## StrongParameter使えないため1レコードずつinsert
                @possessedSkill = PossessedSkill.new(employee_number: insert["employee_number"],
                                                     skill_id: insert["skill_id"],
                                                     month: insert["month"])
                unless @possessedSkill.save
                  flag = false
                end
              else
                flash[:danger] = 'スキル「' + getSkillName(insert["skill_id"]) + '」は未経験扱いとなるので登録しませんでした。'
              end
            end
          }
        end
        ## skill_id_listにはなくpossessedSkillsNowにある場合 → delete
        if diff[1].present?
          unless PossessedSkill.where(employee_number: params["user"]["employee_number"], skill_id: diff[1]).delete_all
            flag = false
          end
        end
      elsif possessedSkillsNow.size > skill_id_list.size
        ## skill_id_listにはなくpossessedSkillsNowにある場合 → delete
        if diff[1].present?
          unless PossessedSkill.where(employee_number: params["user"]["employee_number"], skill_id: diff[1]).delete_all
            flag = false
          end
        end
        ## possessedSkillsNowにはなくskill_id_listにある場合 → insert
        if diff[0].present?
          params[:possessedSkill].values.map { |insert|
            if diff[0].include?(insert["skill_id"].to_i)
              ## 経験年数が0ヶ月(以下)の場合は未経験とみなし対象外
              if insert["month"].to_i > 0
                ## StrongParameter使えないため1レコードずつinsert
                @possessedSkill = PossessedSkill.new(employee_number: insert["employee_number"],
                                                     skill_id: insert["skill_id"],
                                                     month: insert["month"])
                unless @possessedSkill.save
                  flag = false
                end
              else
                flash[:danger] = 'スキル「' + getSkillName(insert["skill_id"]) + '」は未経験扱いとなるので登録しませんでした。'
              end
            end
          }
        end
      ## possessedSkillsNowとskill_id_listの件数が同じ
      else
        ## 中身も一致(1件以上) → update
        if possessedSkillsNow == skill_id_list and skill_id_list.size > 0
          params[:possessedSkill].values.map { |update|
            unless PossessedSkill.where(employee_number: params["user"]["employee_number"], skill_id: update["skill_id"]).update_all(month: update["month"])
              flag = false
            end
          }
        end
        ## possessedSkillsNowにはなくskill_id_listにある場合 → insert
        if diff[0].present?
          params[:possessedSkill].values.map { |insert|
            if diff[0].include?(insert["skill_id"].to_i)
              ## 経験年数が0ヶ月(以下)の場合は未経験とみなし対象外
              if insert["month"].to_i > 0
                ## StrongParameter使えないため1レコードずつinsert
                @possessedSkill = PossessedSkill.new(employee_number: insert["employee_number"],
                                                     skill_id: insert["skill_id"],
                                                     month: insert["month"])
                unless @possessedSkill.save
                  flag = false
                end
              else
                flash[:danger] = 'スキル「' + getSkillName(insert["skill_id"]) + '」は未経験扱いとなるので登録しませんでした。'
              end
            end
          }
        end
        ## skill_id_listにはなくpossessedSkillsNowにある場合 → delete
        if diff[1].present?
          unless PossessedSkill.where(employee_number: params["user"]["employee_number"], skill_id: diff[1]).delete_all
            flag = false
          end
        end
      end
      if flag
        flash[:success] = @user.name + 'さんの情報更新しました。'
        redirect_to root_url
      end
    else
      @user = User.find(params[:id])
      invalidUrl(@user)
      @skills = Skill.all
      ## 経歴の長い順に取得
      @possessedSkills = PossessedSkill.where(employee_number: params[:id]).order(month: "DESC")
    end
  end

  def confirm
    ## 自身の情報を更新は除く
    unless current_user.employee_number.eql?(params[:employeeNumber].to_i)
      invalidUrl()
    end
    return if response_body ## 一般ユーザーのみ強制リダイレクト
    ## 登録画面か更新画面からの遷移ではない場合は
    unless request.referer or params[:name].present?
      flash[:danger] = '登録画面か更新画面から遷移してください。'
      redirect_to root_url
    else
      ## 遷移元の情報を取得
      before_uri = URI.parse(request.referer)
      path = Rails.application.routes.recognize_path(before_uri.path)
      @actionName = path[:action]
      ## 登録画面か更新画面からの遷移ではない場合は
      unless @actionName == 'new' or @actionName == 'edit'
        flash[:danger] = '登録画面か更新画面から遷移してください。'
        redirect_to root_url
      end
      ## 誕生日(パラメータ用と表示用で分けている)
      @birthday_param = getConcatThreeItems(
                          params[:birthday_year].to_s, 
                            format("%02d",params[:birthday_month]),
                              format("%02d",params[:birthday_day]), '-')
      @birthday_display = params[:birthday_year] + '年' +
                          params[:birthday_month] + '月' + params[:birthday_day] + '日'
      ## 電話番号
      @telephone_param = getConcatThreeItems(
                          params[:tel1].to_s, params[:tel2].to_s, 
                            params[:tel3].to_s, '-')
      ## 参画可能日(入力した場合にパラメータ用と表示用で分けている)
      if params[:join_year].present? and params[:join_month].present? and params[:join_day].present?
        @join_param = getConcatThreeItems(
                        params[:join_year].to_s, 
                          format("%02d",params[:join_month]),
                            format("%02d",params[:join_day]), '-')
        @join_display = params[:join_year] + '年' + params[:join_month] + '月' + params[:join_day] + '日 ～'
      end
      ## スキル
      @skillList = []
      params[:skill].each_with_index do |s, index|
        if s.present?
          ## 経験年数の設定
          year = params[:exp_year][index].empty? ? 0 : params[:exp_year][index].to_i
          month = params[:exp_month][index].empty? ? 0 : params[:exp_month][index].to_i
          @skillList[index] = s, year, month
        end
      end
    end
  end

  def detail
    @user = getUser(params[:id])
    invalidUrl(@user)
    @possessedSkills = PossessedSkill.where(employee_number: params[:id]).order(month: "DESC")
    ## 参画しているか(終了日がnil)
    @join = ProjectMember.where("employee_number = ? AND end_date is null", params[:id]).order(start_date: "DESC").first
  end

  def index
    invalidUrl()
    ## エンジニア検索画面から検索が返ってきた場合
    if params[:format].present?
      @users = @@result
      ## usersインスタンス変数に入れた後に初期化する
      @@result = []
    else
      ## エンジニア(一般ユーザー)のみ抽出
      @users = getAllUser.engineer.paginate(page: params[:page])
    end
  end

  def destroy
    deleteFlag = true
    ## ユーザー情報
    @user = getUser(params[:id])
    unless @user.destroy
      deleteFlag = false
    end
    ## 保持スキル(ある場合)
    @possessedSkills = PossessedSkill.where(employee_number: params[:id])
    if @possessedSkills
      unless @possessedSkills.delete_all
        deleteFlag = false
      end
    end
    ## 案件要員(ある場合)
    @projectMember = ProjectMember.where(employee_number: params[:id])
    if @projectMember
      unless @projectMember.delete_all
        deleteFlag = false
      end
    end
    if deleteFlag
      flash[:success] = @user.name + 'さんの情報を削除しました。'
      redirect_to users_url
    end
  end

  def search
    invalidUrl()
    if request.post?
      ## DBからは氏名(like検索)とスキル(IN検索)で絞る
      ## スキル
      if params[:skills]
        ## スキル以外に他に入力されている場合
        if params[:name].present? or params[:age_from].present? or params[:age_to].present?
          jouken = ""
          params[:skills].each_with_index do |skill, index|
            jouken = jouken + "skill_id = " + skill
            if index < params[:skills].count - 1
              jouken.concat(" AND ")
            end
          end
        ## スキルのみ入力されている場合
        else
          ## 選択したスキルが1つの場合
          if params[:skills].count == 1
            jouken = "skill_id = ?"
          elsif params[:skills].count >= 2
            jouken = "skill_id IN (?)"
          end
        end
        unless jouken.empty?
          ## 管理者はスキルがないため管理者フラグの判定は不要
          @users = User.joins("INNER JOIN possessed_skills ON users.employee_number = possessed_skills.employee_number")
                        .where("name like ?", "%"+params[:name]+"%").where(jouken, params[:skills]).distinct.paginate(page: params[:page])
        end
      else
        @users = User.where("admin_flag <> true AND name like ?", "%"+params[:name]+"%").paginate(page: params[:page])
      end
      ## 年齢
      if params[:age_from].present? and params[:age_to].present?
        count = 0
        @users.each do |user|
          age = getAge(user.birthday)
          if params[:age_from].to_i <= age and age <= params[:age_to].to_i
            @@result[count] = user.employee_number
            count = count + 1
          end
        end
        @@result = User.where(employee_number: @@result).paginate(page: params[:page])
      else
        @@result = @users
      end
      redirect_to users_path @@result
    else
      @skills = Skill.all
      ## デフォルトの場合はエンジニアの件数を取得
      @count = User.engineer.count
    end
  end

  private

    def user_params
      params.require(:user).permit(:employee_number, :name, :department,
                                   :birthday, :nearest_station,
                                   :telephone_number, :join_able_date, :password)
    end

    def skill_params
      params.require(:possessedSkill).permit(:employee_number, :skill_id, :month)
    end

    ## 正しいURLか(正しくない場合はリダイレクトされる)
    def invalidUrl(user=nil)
      if user
        unless current_user.admin_flag
          unless user.employee_number == current_user.employee_number
            flash[:danger] = '一般ユーザーが他人のユーザーの情報にアクセスできません。'
            redirect_to root_url
          end
        end
      elsif !current_user.admin_flag
        flash[:danger] = '管理者以外のユーザーはアクセスできません。'
        redirect_to root_url
      end
    end

    ## エンジニア新規登録画面にてランダムの社員番号を取得するメソッド
    def getRandomEmployeeNumber
      employeeList = User.all.pluck(:employee_number)
      flag = false
      ## 11111111～99999999のすでにある社員番号以外の値を取得するまでループ
      while !flag
        employee_number = Random.new.rand(11111111..99999999)
        if !employeeList.include?(employee_number)
          flag = true
        end
      end
      return employee_number
    end

    def getUser(employee_number)
      return User.find(employee_number) 
    end

    def getAllUser
      return User.all.order(:employee_number)
    end

    ## スキルIDからスキル名を取得するメソッド
    def getSkillName(skill_id)
      return Skill.find_by(skill_id: skill_id).skill_name
    end

    ## 誕生日から実年齢を取得するメソッド
    def getAge(birthday)
      today = Date.today.to_time.strftime('%Y%m%d').to_i
      birth = birthday.to_time.strftime('%Y%m%d').to_i
      return ((today - birth)/10000).to_i
    end

    ## 3項目から1つの項目に連結した文字列を返す
    def getConcatThreeItems(first, second, third, moji)
      return first + moji + second + moji + third
    end

end