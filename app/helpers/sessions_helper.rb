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
  
  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def curent_user?(user)
    user == current_user
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 記憶しているURL (もしくはデフォルト値) にリダイレクトする
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを記憶しておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

end