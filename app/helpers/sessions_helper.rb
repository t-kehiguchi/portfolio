module SessionsHelper

  # 引数に渡されたユーザーでログインする
  def log_in(user)
    session[:employee_number] = user.employee_number
  end
  
  # 現在のユーザーをログアウトする
  def log_out
    session.delete(:employee_number)
    @current_user = nil
  end
  
  # 現在ログイン中のユーザーを返す (ただし、いる場合のみ)
  def current_user
    if session[:employee_number]
      @current_user ||= User.find_by(employee_number: session[:employee_number])
    end
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

end