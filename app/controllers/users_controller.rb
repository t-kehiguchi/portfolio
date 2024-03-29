require 'securerandom'

class UsersController < ApplicationController

  ## 検索結果
  @@result = []
  ## 未参画情報、当月終了予定者情報、翌月終了予定者情報
  @@notJoinInfo, @@thisMonthInfo, @@nextMonthInfo = [], [], []
  ## JOIN句(定数)
  JOIN_PHASE = ["INNER JOIN possessed_skills ON users.employee_number = possessed_skills.employee_number",
                "LEFT OUTER JOIN project_members ON users.employee_number = project_members.employee_number",
                "INNER JOIN project_members ON users.employee_number = project_members.employee_number"]
  ## 参画有無(定数)
  JOIN_OR_NOT = ["無", "有"]
  ## 性別(定数)
  GENDER = {"male":"男性", "female":"女性"}
  ## 就業形態(定数)
  WORKING_STYLE = {"fullTime":"正社員", "contract":"契約社員", "subcontract":"業務委託"}
  ## Userモデルのパラメータカラム
  USER_PARAMS = [:employee_number, :name, :gender, :department, :birthday, :nearest_station, :telephone_number, :price_min, :price_max, :working_style, :join_able_date, :description, :password]

  def new
    invalidUrl()
    if request.post?
      flag = true
      ## エンジニア情報
      @user = User.new(user_params(params["user"]["password"]))
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
      unless @user.update_attributes(user_params(params["user"]["password"]))
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
      ## 参画終了予定日
      @latestJoinInfo = ProjectMember.where(employee_number: params["user"]["employee_number"]).order(start_date: "DESC").limit(1)
      if @latestJoinInfo.present?
        endDate = params["user"]["join_end_date"].present? ? params["user"]["join_end_date"] : nil
        unless @latestJoinInfo.update_all(end_date: params["user"]["join_end_date"])
          flag = false
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
      ## 最新の参画情報取得(1レコードのみ)
      @latestJoinInfo = ProjectMember.where(employee_number: params[:id]).order(start_date: "DESC").limit(1)[0]
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
      ## 性別(表示用)
      @gender_display = GENDER[params[:gender].to_sym]
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
      ## 就業形態(表示用)
      @working_style_display = WORKING_STYLE[params[:workingStyle].to_sym]
      ## 参画可能日(入力した場合にパラメータ用と表示用で分けている)
      @join_param = params[:joinAbleDate] if params[:joinAbleDate].present?
      @join_display = Date.parse(params[:joinAbleDate]).strftime("%Y年%-m月%-d日 ～") if params[:joinAbleDate].present?
      ## 参画終了予定日(入力した場合にパラメータ用と表示用で分けている)
      @join_end_param = params[:joinEndDate] if params[:joinEndDate].present?
      @join_end_display = Date.parse(params[:joinEndDate]).strftime("～ %Y年%-m月%-d日") if params[:joinEndDate].present?
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
    @join = ProjectMember.where("employee_number = ? AND (end_date is null OR #{Date.today.strftime("%Y-%m-%d")} <= end_date)", params[:id]).order(start_date: "DESC").first
    ## お気に入り案件(チェックした順)
    @favoriteProjects = ProjectMatching.where(employee_number: params[:id]).order(created_at: "ASC").pluck(:project_id, :created_employee_number)
    ## スキルシート情報(最近アップロードした情報を1レコード取得)
    @skillSheetInfo = SkillSheet.where(employee_number: params[:id]).order(created_at: "DESC").first
  end

  def index
    invalidUrl()
    ## パラメータ指定のリクエストの場合
    if params[:id].present?
      ## 未参画
      if "notJoin".eql?(params[:id])
        @users, users = @@notJoinInfo.paginate(page: params[:page], per_page: 25).page(params[:page]), @@notJoinInfo
      ## 当月終了予定
      elsif "thisMonth".eql?(params[:id])
        @users, users = @@thisMonthInfo.paginate(page: params[:page], per_page: 25).page(params[:page]), @@thisMonthInfo
      ## 翌月終了予定
      elsif "nextMonth".eql?(params[:id])
        @users, users = @@nextMonthInfo.paginate(page: params[:page], per_page: 25).page(params[:page]), @@nextMonthInfo
      end
    else
      ## エンジニア検索画面から検索が返ってきた場合
      if params[:format].present?
        @users, users = @@result.paginate(page: params[:page], per_page: 25).page(params[:page]), @@result
      else
        ## エンジニア(一般ユーザー)のみ抽出
        @users, users = getAllUser.engineer.paginate(page: params[:page], per_page: 25), getAllUser.engineer
      end
    end
    ## サマリー情報
    ids = users.map { |user| user.employee_number }
    ## 要員数合計
    @count = User.engineer.count
    ## 未参画人数
    notJoinCountId = users.pluck(:employee_number) - ProjectMember.where(employee_number: ids).pluck(:employee_number)
    @notJoinCount = users.where(employee_number: notJoinCountId)
    systemDate = Date.today
    ## 当月終了予定人数
    @thisMonthEndNum = getJoinEndEngineerInfo(ids, systemDate.beginning_of_month.to_s, systemDate.end_of_month.to_s)
    ## 翌月終了予定人数
    @nextMonthEndNum = getJoinEndEngineerInfo(ids, systemDate.next_month.beginning_of_month.to_s, systemDate.next_month.end_of_month.to_s)
    ## クラス内で保持するためにそれぞれクラス変数に格納
    @@notJoinInfo, @@thisMonthInfo, @@nextMonthInfo = @notJoinCount, @thisMonthEndNum, @nextMonthEndNum
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
    ## 案件マッチング(ある場合)
    @projectMatching = ProjectMatching.where(employee_number: params[:id])
    if @projectMatching
      unless @projectMatching.delete_all
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
      ## resultクラス変数を初期化
      @@result = []
      ## DBからは氏名(like検索)とスキル(IN検索)と参画有無(結合)で絞る
      ## 参画有無
      if params[:joinOrNot]
        ## 参画無
        if params[:joinOrNot] == JOIN_OR_NOT[0]
          joins = JOIN_PHASE[1]
          joinsJouken = "start_date is null AND end_date is null"
        ## 参画有
        elsif params[:joinOrNot] == JOIN_OR_NOT[1]
          joins = JOIN_PHASE[2]
          now = Date.today.strftime("%Y-%m-%d")
          joinsJouken = "(start_date is not null AND end_date is null) OR (#{now} <= end_date)"
        end
      end
      ## スキル
      if params[:skills]
        ## スキル以外に他に入力されている場合(年齢は両方入力か両方未入力)
        if params[:name].present? or (params[:age_from].present? and params[:age_to].present?) or (params[:age_from].empty? and params[:age_to].empty?)
          jouken = ""
          params[:skills].each_with_index do |skill, index|
            jouken = jouken + "skill_id = " + skill
            if index < params[:skills].count - 1
              jouken.concat(" OR ")
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
          @users = params[:joinOrNot].empty? ?
                    User.joins(JOIN_PHASE[0]).where("name like ?", "%"+params[:name]+"%").where(jouken, params[:skills]).distinct :
                     User.joins(JOIN_PHASE[0]).joins(joins).where("name like ?", "%"+params[:name]+"%").where(jouken, params[:skills]).where(joinsJouken).distinct.order(:employee_number)
        end
      else
        @users = params[:joinOrNot].empty? ?
                  User.where("admin_flag <> true AND name like ?", "%"+params[:name]+"%") :
                   User.joins(joins).where("admin_flag <> true AND name like ?", "%"+params[:name]+"%").where(joinsJouken).distinct.order(:employee_number)
      end
      ## 参画終了日(入力日付の1か月前 ≦ 参画終了日 ≦ 入力日付の1か月後)
      @users = User.joins(JOIN_PHASE[2])
                    .where("users.employee_number in (?) AND end_date BETWEEN ? AND ?",
                      @users.pluck(:employee_number),
                      (Date.parse(params[:joinEndDate]) << 1).strftime("%Y-%m-%d"),
                      (Date.parse(params[:joinEndDate]) >> 1).strftime("%Y-%m-%d")).order(:employee_number) if params[:joinEndDate].present? and @users.pluck(:employee_number).present?
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
        @@result = User.where(employee_number: @@result)
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

  def matching
    invalidUrl()
    ## 該当エンジニアのスキル(スキルIDの昇順)
    userSkills = PossessedSkill.where(employee_number: params[:id]).pluck(:skill_id).sort
    ## 最終的にポイントのないレコードは削除する
    @skillMatchInfos = skillMatchInfo(userSkills).delete_if {|key, value| value[0].to_i < 1}.to_a.paginate(page: params[:page], per_page: 10)
    ## お気に入り案件
    @favoriteProjects = ProjectMatching.where(employee_number: params[:id]).pluck(:project_id)
  end

  def upload
    ## ファイルアップロード処理(begin-rescue)
    begin
      upload_file_name = params[:skillSheet].original_filename
      if Rails.env.production? ## 本番(ステージング)環境
        client = Aws::S3::Client.new(:region => ENV['AWS_S3_REGION'], :access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']) ## リージョン「東京」
        client.put_object(bucket: ENV['S3_BUCKET_NAME'], key: params[:id].to_s + '/' + upload_file_name, body: params[:skillSheet].tempfile.read)
      else ## 開発環境
        ## ディレクトリ
        upload_dir = Rails.root.join("public", params[:id].to_s)
        ## フォルダ作成(存在しない場合のみ)
        FileUtils.mkdir_p(upload_dir) unless File.exists?(upload_dir)
        ## アップロードするファイルのフルパス
        upload_file_path = upload_dir + upload_file_name
        ## アップロードファイルの書き込み(一時フォルダのファイルから格納先へコピーで対応)
        FileUtils.cp(params[:skillSheet].tempfile, upload_file_path)
      end
    rescue => e
      puts e.class
      flash[:danger] = 'ファイルアップロード失敗しました。'
      return
    end
    ## スキルシートテーブルに保存する処理
    flag = true
    ## file_id生成(英数字ランダム8桁)
    file_id = SecureRandom.alphanumeric(8)
    ## 対象の社員番号に紐づくスキルシートテーブルのレコードが存在する場合は全件削除
    skillSheetTemp = SkillSheet.where(employee_number: params[:id])
    skillSheetTemp.delete_all if skillSheetTemp.present?
    ## スキルシートテーブルのレコード追加
    @skillSheet = SkillSheet.new(file_id: file_id, employee_number: params[:id], file_name: upload_file_name)
    unless @skillSheet.save
      flag = false
    end
    if flag
      flash[:success] = 'ファイル名「' + upload_file_name + '」' + 'アップロード完了しました。'
    else
      flash[:danger] = 'ファイルアップロード失敗しました。'
    end
  end

  def download
    ## ファイル名取得
    skill_sheet = SkillSheet.where(employee_number: params[:id])
    ## 空か2件以上の場合はエラー
    if skill_sheet.empty? or skill_sheet.count > 1
      user = User.find(params[:id])
      flash[:danger] = 'スキルシート情報が0件か複数件存在します。'
      return redirect_back(fallback_location: user_detail_path(user))
    end
    file_name = skill_sheet.first.file_name
    ## アップロード先のファイルが存在しない場合もエラー
    fileExistFlag = true
    if Rails.env.production? ## 本番(ステージング)環境
      bucket = Aws::S3::Resource.new(:region => ENV['AWS_S3_REGION'], :access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']).bucket(ENV['S3_BUCKET_NAME'])
      fileExistFlag = false unless bucket.object(params[:id].to_s + '/' + file_name).exists?
    else
      ## ダウンロードするファイルのフルパス
      upload_dir = Rails.root.join("public", params[:id].to_s)
      upload_file_path = upload_dir + file_name
      fileExistFlag = false unless File.exists?(upload_file_path)
    end
    unless fileExistFlag
      user = User.find(params[:id])
      flash[:danger] = '対象のファイルが削除されたかファイル名に相違があります。'
      return redirect_back(fallback_location: user_detail_path(user))
    end
    ## ファイル種類(拡張子で決定)
    type = file_name.end_with?(".xlsx") ? "application/xlsx" : file_name.end_with?(".xls") ? "application/xls" : "application/pdf"
    begin
      if Rails.env.production? ## 本番(ステージング)環境
        client = Aws::S3::Client.new(:region => ENV['AWS_S3_REGION'], :access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']) ## リージョン「東京」
        data = client.get_object(:bucket => ENV['S3_BUCKET_NAME'], :key => params[:id].to_s + '/' + file_name).body
        send_data data.read, filename: file_name, disposition: 'attachment',  type: type
      else ## 開発環境
        ## ダウンロード
        send_file(upload_file_path, filename: file_name, type: type)
      end
    rescue => e
      puts e.class
      flash[:danger] = 'ダウンロード失敗しました。'
      return redirect_back(fallback_location: user_detail_path(user))      
    end
  end

  private

    def user_params(password)
      list = password.present? ? USER_PARAMS : USER_PARAMS - [:password]
      params.require(:user).permit(list)
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

    ## 月初と月末を指定して終了予定日に該当するエンジニアを取得するメソッド
    def getJoinEndEngineerInfo(users, targetStartDate, targetEndDate)
      return User.joins("INNER JOIN project_members ON users.employee_number = project_members.employee_number")
               .where(employee_number: users)
               .where("end_date BETWEEN ? AND ?", targetStartDate, targetEndDate)
    end

    ## 該当の必須及び尚可スキルからマッチする案件情報を取得
    def skillMatchInfo(userSkills)
      matchInfoHash = {}
      ## 必須スキル(案件番号ごとに必須スキルIDのリストをHash形式で取得する)
      mustSkills = getHashOfSkillListPerProjectId(ProjectMustSkill.order(:project_id).pluck(:project_id, :must_skill_id))
      ## 尚可スキル(案件番号ごとに尚可スキルIDのリストをHash形式で取得する)
      wantSkills = getHashOfSkillListPerProjectId(ProjectWantSkill.order(:project_id).pluck(:project_id, :want_skill_id))
      mustSkills.each do |pid, sid|
        point = 0
        point = point + (userSkills & sid).count
        skillList = []
        (userSkills & sid).map {|ms| skillList.push ms}
        ## 同案件で尚可スキルもある場合
        if wantSkills[pid].present?
          wsid = wantSkills[pid]
          ## 必須スキルと尚可スキル重複している場合は対象外(その分取り除く)
          wsid = wsid - sid if (sid & wsid).present?
          point = point + (userSkills & wsid).count * 2
          (userSkills & wsid).map {|ws| skillList.push ws}
        end
        matchInfoHash[pid] = [point, skillList]
      end
      ## ポイントの高い順に並べ替え(ポイントが同一なら案件番号の昇順)
      return (matchInfoHash.sort_by {|a, b| [-b[0], a]}).to_h
    end

    ## Hash形式で案件番号ごとにスキルIDのリストを生成するメソッド
    def getHashOfSkillListPerProjectId(skillInfos)
      hash = {}
      projectId, skillIds = "", ""
      skillInfos.each_with_index do |skillPerProjectId, index|
        if projectId.present? and projectId != skillPerProjectId[0]
          hash[projectId] = skillIds.split(",").map(&:to_i)
          skillIds = ""
        end
        projectId = (projectId.empty? or projectId != skillPerProjectId[0]) ? skillPerProjectId[0] : projectId
        skillIds = skillIds + skillPerProjectId[1].to_s + "," if projectId == skillPerProjectId[0]
        ## リストの最後もHashに格納
        hash[projectId] = skillIds.split(",").map(&:to_i) if (index+1) == skillInfos.count
      end
      return hash
    end
end