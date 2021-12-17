module Api
  module V1
    class UsersController < ApplicationController

      ## JOIN句(定数)
      JOIN_PHASE = ["INNER JOIN possessed_skills ON users.employee_number = possessed_skills.employee_number",
                    "LEFT OUTER JOIN project_members ON users.employee_number = project_members.employee_number",
                    "INNER JOIN project_members ON users.employee_number = project_members.employee_number"]
      ## 参画有無(定数)
      JOIN_OR_NOT = ["無", "有"]

      def search
        ## 検索結果
        result = []
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
              result[count] = user.employee_number
              count = count + 1
            end
          end
          result = User.where(employee_number: result)
        else
          result = @users
        end
        render json: result.count
      end

      def favorite
        ## Postメソッドのみ実行
        if request.post?
          ## params[:favorite]が文字列で渡されるので、boolean型に変換する
          params[:favorite] = params[:favorite] == "true" ? true : false
          if params[:favorite] ## trueの場合、レコード登録(案件番号、社員番号、ログイン社員番号(基本的に管理者))
            params[:created_employee_number] = current_user.employee_number
            @projectMatching = ProjectMatching.new(project_matching_params)
            @projectMatching.save
          else ## falseの場合、押下した案件番号と社員番号に紐づくレコード削除
            @projectMatching = ProjectMatching.where(project_id: params[:project_id], employee_number: params[:employee_number])
            @projectMatching.delete_all
          end
        else
          ## それ以外(Getメソッド)の場合はエンジニア一覧 or エンジニア詳細画面 or ログイン画面へ遷移
          ## ログイン時のみユーザー情報取得
          user = User.find(current_user.employee_number) if current_user.present?
          flash[:danger] = '不正なリクエストです。'
          redirect_to root_url user
        end
      end

      private

        def project_matching_params
          params.permit(:project_id, :employee_number, :created_employee_number)
        end

        ## 誕生日から実年齢を取得するメソッド
        def getAge(birthday)
          today = Date.today.to_time.strftime('%Y%m%d').to_i
          birth = birthday.to_time.strftime('%Y%m%d').to_i
          return ((today - birth)/10000).to_i
        end

    end
  end
end