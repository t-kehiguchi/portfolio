class SessionsController < ApplicationController

  def create
    user = User.find_by(employee_number: params[:session][:employee_number])
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      if user.admin_flag?
        redirect_to users_url
      else
        redirect_to user_detail_url user
      end
    else
      flash[:danger] = '社員番号とパスワードが一致しませんでした。'
      render 'static_pages/top'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

end