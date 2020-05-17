module Api
  module V1
    class UsersController < ApplicationController

      def search
        ## 検索結果
        result = []
        ## DBからは氏名(like検索)とスキル(IN検索)で絞る
        ## スキル
        if params[:skills]
          ## スキル以外に他に入力されている場合(年齢は両方入力か両方未入力)
          if params[:name].present? or (params[:age_from].present? and params[:age_to].present?) or (params[:age_from].empty? and params[:age_to].empty?)
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
                          .where("name like ?", "%"+params[:name]+"%")
                            .where(jouken, params[:skills]).distinct
          end
        else
          @users = User.where("admin_flag <> true AND name like ?", "%"+params[:name]+"%")
        end
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

      private

        ## 誕生日から実年齢を取得するメソッド
        def getAge(birthday)
          today = Date.today.to_time.strftime('%Y%m%d').to_i
          birth = birthday.to_time.strftime('%Y%m%d').to_i
          return ((today - birth)/10000).to_i
        end

    end
  end
end