class StaticPagesController < ApplicationController
  def top
    if logged_in?
      if current_user.admin_flag?
        ## 管理者はエンジニア一覧画面へ遷移
        redirect_to users_url
      else
        ## 一般ユーザーはエンジニア一覧画面へ遷移
        redirect_to user_detail_url current_user
      end
    end
  end
end
