module Api
  module V1
    class ProjectsController < ApplicationController

      ## SQL結合文字列(長いのでここで定義)
      @@joinQuery = "LEFT OUTER JOIN project_members m ON projects.project_id = m.project_id
                      LEFT OUTER JOIN project_must_skills ms ON projects.project_id = ms.project_id
                        LEFT OUTER JOIN project_want_skills ws ON projects.project_id = ws.project_id"

      def search
        ## 検索結果
        result = []
        ## 条件配列
        jouken = ["","",""]
        ## 単価
        if params[:price].present?
          ## 「〇〇円 ～ 〇〇円」を選択した場合
          if params[:price].include?("BETWEEN")
            min = params[:price]["BETWEEN".length+1..params[:price].index("AND")-2]
            max = params[:price][params[:price].index("AND")+"AND".length+1..]
            jouken[0] = sprintf(" AND ((price_min IS NOT NULL AND price_max IS NOT NULL AND (price_min %s OR price_max %s))
                                    OR (price_min IS NULL AND price_max IS NOT NULL AND price_max <= %d)
                                      OR (price_min IS NOT NULL AND price_max IS NULL AND price_min <= %d))",
                                        params[:price], params[:price], max, min)
          ## 「～ 〇〇円」や「〇〇円 ～」を選択した場合
          else
            jouken[0] = " AND (price_min IS NOT NULL AND price_min #{params[:price]}) OR (price_max IS NOT NULL AND price_max #{params[:price]})"
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
        ## 参画エンジニア
        if params[:engineer].present?
          jouken[2] = " AND m.employee_number = " + params[:engineer]
        end
        result = Project.joins(@@joinQuery)
                  .where("1 = 1" + jouken[0] + jouken[1] + jouken[2], params[:skills], params[:skills])
                    .order(project_id: "DESC").distinct
        render json: result.count
      end

    end
  end
end