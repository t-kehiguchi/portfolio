class ProjectsController < ApplicationController

  ## 検索結果
  @@result = []
  ## SQL結合文字列(長いのでここで定義)
  @@joinQuery = "LEFT OUTER JOIN project_members m ON projects.project_id = m.project_id
                  LEFT OUTER JOIN project_must_skills ms ON projects.project_id = ms.project_id
                    LEFT OUTER JOIN project_want_skills ws ON projects.project_id = ws.project_id"
  ## 参画有無(定数)
  JOIN_OR_NOT = ["無", "有"]

  def new
    invalidUrl()
    if request.post?
      flag = true
      ## 案件情報
      @project = Project.new(project_params)
      unless @project.save
        flag = false
      end
      ## 必須スキル情報
      mustSkillHash = params["mustSkill"].map(&:to_i).filter {|mustSkill| mustSkill > 0}
      unless skillReplace(mustSkillHash, params["project"]["project_id"], "must")
        flag = false
      end
      ## 尚可スキル情報(あれば)
      if params["wantSkill"].present?
        wantSkillHash = params["wantSkill"].map(&:to_i).filter {|wantSkill| wantSkill > 0}
        if wantSkillHash.present?
          unless skillReplace(wantSkillHash, params["project"]["project_id"], "want")
            flag = false
          end
        end
      end
      if flag
        flash[:success] = '案件「' + @project.project_name + '」の情報を登録しました。'
        redirect_to projects_url
      end
    else
      ## 新規採番する案件IDを取得
      @project_id = getNewestProjectIdWithDate(Date.today.strftime("%Y%m%d"))
      @skills = Skill.all.pluck(:skill_id, :skill_name)
    end
  end

  def edit
    invalidUrl()
    if request.post?
      flag = true
      @project = Project.find(params["project"]["project_id"])
      unless @project.update_attributes(project_params)
        flag = false
      end
      ## 必須スキル情報
      mustSkillHash = params["mustSkill"].map(&:to_i).filter {|mustSkill| mustSkill > 0}
      unless skillReplace(mustSkillHash, params["project"]["project_id"], "must")
        flag = false
      end
      ## 尚可スキル情報(あれば)
      wantSkillHash = params["wantSkill"] ? params["wantSkill"].map(&:to_i).filter {|wantSkill| wantSkill > 0} : []
      unless skillReplace(wantSkillHash, params["project"]["project_id"], "want")
        flag = false
      end
      ## 参画メンバー(既存メンバーを全て削除するだけのパターン(パラメータ自体来ない)もある)
      params["joinAbleMember"] = params["joinAbleMember"] ? params["joinAbleMember"] : {}
      unless projectMembersReplace(params["project"]["project_id"], params["joinAbleMember"])
        flag = false
      end
      if flag
        flash[:success] = '案件「' + @project.project_name + '」の情報更新しました。'
        redirect_to projects_url
      end
    else
      @project = Project.find(params[:id])
      @must = ProjectMustSkill.where(project_id: params[:id]) ## 必須スキル
      @want = ProjectWantSkill.where(project_id: params[:id]) ## 尚可スキル
      @skills = Skill.all.pluck(:skill_id, :skill_name)
      @joinEngineer = ProjectMember.where(project_id: params[:id]) ## 参画メンバー
      ## 参画可能メンバー(どの案件にも参画していないエンジニア)
      @joinAbleEngineer = User.engineer.where("employee_number not in (?)", ProjectMember.pluck(:employee_number)).pluck(:employee_number, :name)
    end
  end

  def confirm
    invalidUrl()
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
      ## 開始日(パラメータ用と表示用で分けている)
      @start_param = params[:projectStartDate]
      @start_display = Date.parse(params[:projectStartDate]).strftime("%Y年%-m月%-d日 ～")
      ## 終了予定日(入力した場合にパラメータ用と表示用で分けている)
      @end_param = params[:projectEndDate] if params[:projectEndDate].present?
      @end_display = Date.parse(params[:projectEndDate]).strftime("～ %Y年%-m月%-d日") if params[:projectEndDate].present?
      ## 時間
      @startTime = params[:time_from]
      @endTime   = params[:time_to]
      ## スキル(重複している可能性がある、尚可スキルは選択されていない場合はある)
      @must = params[:mustSkill].uniq
      @want = params[:wantSkill] ? params[:wantSkill].uniq : nil
      ## 参画メンバー(新規参画メンバーと既存参画メンバーの両方がある場合はHashのマージ)
      joinAble = params[:joinAble] ? params[:joinAble].permit(params[:joinAble].keys) : {}
      joinAbleAlready = params[:joinAbleAlready] ? params[:joinAbleAlready].permit(params[:joinAbleAlready].keys) : {}
      @joinAbleMember = joinAble.empty? ? joinAbleAlready
                          : joinAbleAlready.empty? ? joinAble
                            : joinAble.merge(joinAbleAlready).permit!.to_h.sort {|x, y| x <=> y}.to_h
    end
  end

  def detail
    @project = Project.find(params[:id])
    @projectSkills = ProjectMustSkill.where(project_id: params[:id])
    @projectWantSkills = ProjectWantSkill.where(project_id: params[:id])
    @projectMembers = ProjectMember.where(project_id: params[:id])
  end

  def index
    ## 案件検索画面から検索が返ってきた場合
    if params[:format].present?
      @projects = @@result.page(params[:page])
    else
      @projects = getAllProjects.paginate(page: params[:page], per_page: 10)
    end
    ## 登録案件数合計
    @count = params[:format].present? ? getAllProjects.count : @projects.count
    @projectSkills = ProjectMustSkill.all.order(project_id: "DESC")
  end

  def search
    if request.post?
      ## 条件配列
      jouken = ["","",""]
      ## 単価
      if params[:price].present?
        ## 「〇〇円 ～ 〇〇円」を選択した場合
        if params[:price].include?("BETWEEN")
          min = params[:price]["BETWEEN".length+1..params[:price].index("AND")-2]
          max = params[:price][params[:price].index("AND")+"AND".length+1..]
          jouken[0] = sprintf(" AND ((price_min IS NOT NULL AND price_max IS NOT NULL AND (price_min %s OR price_max %s))
                                  OR (price_min IS NULL AND price_max IS NOT NULL AND price_max >= %d)
                                    OR (price_min IS NOT NULL AND price_max IS NULL AND price_min <= %d))",
                                      params[:price], params[:price], max, min)
        else
          value = params[:price][params[:price].index(" ")+1..]
        end
        ## 「～ 〇〇円」を選択した場合
        if params[:price].include?("<=")
          jouken[0] = " AND ((price_min IS NOT NULL AND price_min <= #{value}) OR (price_max IS NOT NULL AND price_max >= #{value}))"
        ## 「〇〇円 ～」を選択した場合
        elsif params[:price].include?(">=")
          jouken[0] = " AND ((price_min IS NOT NULL AND price_min >= #{value}) OR (price_max IS NOT NULL AND price_max >= #{value}))"
        end
      end
      ## スキル
      if params[:skills]
        ## スキル以外に他に入力されている場合
        if params[:price].present? or params[:engineer].present?
          params[:skills].each do |skill|
            jouken[1]  = jouken[1] + " AND (must_skill_id = " + skill + " OR want_skill_id = " + skill + ")"
          end
        ## スキルのみ入力されている場合
        else
          ## 選択したスキルが1つの場合
          if params[:skills].count == 1
            jouken[1] = " AND must_skill_id = ? OR want_skill_id = ?"
          elsif params[:skills].count >= 2
            jouken[1] = " AND must_skill_id IN (?) OR want_skill_id IN (?)"
          end
        end
      end
      ## 参画有無
      if params[:joinOrNot]
        ## 参画無
        if params[:joinOrNot] == JOIN_OR_NOT[0]
          joinsJouken = "m.start_date is null AND m.end_date is null"
        ## 参画有
        elsif params[:joinOrNot] == JOIN_OR_NOT[1]
          now = Date.today.strftime("%Y-%m-%d")
          joinsJouken = "(m.start_date is not null AND m.end_date is null) OR (#{now} <= m.end_date)"
        end
      end
      ## 参画エンジニア
      if params[:engineer].present?
        jouken[2] = " AND employee_number = " + params[:engineer]
      end
      @@result = Project.joins(@@joinQuery)
                  .where("1 = 1" + jouken[0] + jouken[1] + jouken[2], params[:skills], params[:skills])
                    .where("working_place like ?", "%"+params[:work_place]+"%")
                      .where(joinsJouken)
                        .order(project_id: "DESC").distinct.paginate(page: params[:page], per_page: 10)
      redirect_to projects_path @@result
    else
      @engineers = User.engineer.pluck(:employee_number, :name)
      @skills = Skill.all
      ## デフォルトの場合は案件の件数を取得
      @count = Project.count
    end
  end

  def matching
    invalidUrl()
    ## 案件スキル
    mustSkills = ProjectMustSkill.where(project_id: params[:id]).pluck(:must_skill_id)
    wantSkills = ProjectWantSkill.where(project_id: params[:id]).pluck(:want_skill_id)
    skills = mustSkills.push(wantSkills).flatten!.uniq.sort ## 重複なし
    ## マッチング情報取得(上位10件、未参画、参画可能タイミング)
    @matching, @matchingNotJoin, @matchingJoinableTiming = {}, {}, {}
    skillMatchInfo(skills).each_with_index do |m, index|
      user = User.find(m[0])
      ## 上位10件
      @matching[m[0]] = m[1] if index < 10
      ## 未参画
      @matchingNotJoin[m[0]] = m[1] if @matchingNotJoin.count < 10 and isNotJoin(m[0])
      ## 参画可能タイミング(案件開始日 ≦ 参画可能日)
      @matchingJoinableTiming[m[0]] = m[1] if @matchingJoinableTiming.count < 10 and user.join_able_date.present? and compareDate(Project.find(params[:id]).start_date, user.join_able_date) >= 0
    end
  end

  private

    def project_params
      params.require(:project).permit(:project_id, :project_name, :content,
                                      :environment, :price_min, :price_max, :min,
                                      :max, :start_date, :end_date, :start_time,
                                      :end_time, :working_place, :applicant_num, :description)
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

    def getAllProjects
      return Project.all.order(project_id: "DESC")
    end

    ## 該当日付の最新の案件IDの連番を取得
    def getNewestProjectIdWithDate(date)
      projectId = Project.where("project_id LIKE ?", date+"%").maximum(:project_id)
      return projectId ? date + getNewestProjectId(projectId) : date + "-01"
    end

    ## 最新の案件IDの連番を取得
    def getNewestProjectId(projectId)
      return format("-%02d", (projectId[projectId.index("-")+1..].to_i+1).to_s)
    end

    ## 3項目から1つの項目に連結した文字列を返す
    def getConcatThreeItems(first, second, third, moji)
      return first + moji + second + moji + third
    end

    ## project_must_skillsテーブル及びproject_want_skillsテーブルのReplace処理
    def skillReplace(skills, projectId, skillType)
      diff = [[],[]]
      replaceFlag = true
      if skillType == "must"
        ## 現時点での必須スキルを取得
        mustSkill = ProjectMustSkill.where(project_id: projectId).pluck(:must_skill_id)
        ## 現時点での必須スキルと必須スキル情報との差分を取得
        diff[0] = skills - mustSkill ## 必須スキル情報 - 現時点での必須スキル
        diff[1] = mustSkill - skills ## 現時点での必須スキル - 必須スキル情報
        ## 現時点での必須スキルにはなく必須スキル情報にある場合 → insert
        if diff[0].present?
          diff[0].each do |m|
            @projectMustSkill = ProjectMustSkill.new(project_id: projectId, must_skill_id: m)
            unless @projectMustSkill.save
              replaceFlag = false
            end
          end
        end
        ## 必須スキル情報にはなく現時点での必須スキルにある場合 → delete
        if diff[1].present?
          diff[1].each do |m|
            unless ProjectMustSkill.where(project_id: projectId, must_skill_id: m).delete_all
              replaceFlag = false
            end
          end
        end
      elsif skillType == "want"
        ## 現時点での尚可スキルを取得
        wantSkill = ProjectWantSkill.where(project_id: projectId).pluck(:want_skill_id)
        ## 現時点での尚可スキルと尚可スキル情報との差分を取得
        diff[0] = skills - wantSkill ## 尚可スキル情報 - 現時点での尚可スキル
        diff[1] = wantSkill - skills ## 現時点での尚可スキル - 尚可スキル情報
        ## 現時点での尚可スキルにはなく尚可スキル情報にある場合 → insert
        if diff[0].present?
          diff[0].each do |w|
            @projectWantSkill = ProjectWantSkill.new(project_id: projectId, want_skill_id: w)
            unless @projectWantSkill.save
              replaceFlag = false
            end
          end
        end
        ## 尚可スキル情報にはなく現時点での尚可スキルにある場合 → delete
        if diff[1].present?
          diff[1].each do |w|
            unless ProjectWantSkill.where(project_id: projectId, want_skill_id: w).delete_all
              replaceFlag = false
            end
          end
        end
      end
      return replaceFlag
    end

    ## project_membersテーブルのReplace処理
    def projectMembersReplace(projectId, joinAbleMembers)
      diff = []
      replaceFlag = true
      ## 該当案件の参画メンバーを取得
      alreadyId = ProjectMember.where(project_id: projectId).pluck(:employee_number)
      diff = alreadyId - joinAbleMembers.keys.map(&:to_i) ## 削除対象のメンバー
      ## hash内をループ
      joinAbleMembers.keys.map(&:to_i).map {|joinAbleMember|
        ## joinAbleMembersハッシュのキーは文字列なので一応数値化
        unless alreadyId.include?(joinAbleMember)
          ## レコード追加
          @projectMember = ProjectMember.new(project_id: projectId, employee_number: joinAbleMember, start_date: joinAbleMembers[joinAbleMember.to_s], end_date: nil)
          replaceFlag = @projectMember.save ? true : false
        end
      }
      diff.each do |del|
        ## レコード削除
        replaceFlag = ProjectMember.where(project_id: projectId, employee_number: del).delete_all ? true : false
      end
      return replaceFlag
    end

    ## 該当の必須及び尚可スキルからマッチするエンジニア情報を取得
    def skillMatchInfo(skills)
      matchInfoHash = {}
      User.engineer.each do |e|
        count = 0
        possessedSkill = PossessedSkill.where(employee_number: e.employee_number).pluck(:skill_id)
        possessedSkill.each do |ps|
          if skills.include?(ps)
            count = count + 1
          end
        end
        ## マッチング率 = スキルマッチした数 / skills(必須及び尚可スキル)の数
        matchInfoHash[e.employee_number] = possessedSkill.present? ? (count*100/skills.count).to_f : 0.to_f
      end
      ## マッチング率の高い順に並べ替え(マッチング率が同一なら社員番号の昇順)
      return (matchInfoHash.sort do |a, b| b[1] <=> a[1] || a[1] <=> b[1] end).to_h
    end

    ## 対象ユーザーが末参画か判定するメソッド
    def isNotJoin(user)
      return ProjectMember.where("employee_number = ? AND (end_date is null OR #{Date.today.strftime("%Y-%m-%d")} <= end_date)", user).empty?
    end

end
