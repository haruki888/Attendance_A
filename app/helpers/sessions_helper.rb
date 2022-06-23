module SessionsHelper
  
  #引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user)              #このlog_inヘルパーメソッドを定義したことにより、ユーザーのログインを行ってcreateアクションを完了ユーザー情報ページへリダイレクトする準備が整う
    session[:user_id] = user.id #ユーザーのブラウザ内にある一時的cookiesに暗号化済みのuser.idが自動で生成されます。
  end                           #user.idはsession[:user_id]と記述することで元通りの値を取得することが可能です。    
  
  #セッションと@current＿userを破棄します。
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 現在ログイン中のユーザーがいる場合オブジェクトを返します。
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id:session[:user_id])
    end
  end
  
  # 現在ログイン中のユーザーがいればtrue、そうでなければfalseを返します。
  def logged_in?
    !current_user.nil?
  end
end

