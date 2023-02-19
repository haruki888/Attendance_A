class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception          #CSRF対策(クロスサイトリクエストフォージェリ)
  include SessionsHelper                         #サイトに攻撃用のコードを仕込むことで、アクセスした
                                                  #ユーザーに対し意図しない操作を行わせる攻撃のこと
  $days_of_the_week = %w{日 月 火 水 木 金 土}   #<%= csrf_meta_tags %> applicaiton.html.erb.rbとセット 
          #↑
  #グローバル変数
  #リテラル表記 #["日", "月", "火", "水", "木", "金", "土"]の配列と同じように使えます
  # beforフィルター
  
  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end

  # paramsハッシュからユーザーを取得します。
  def set_user_id
    @user = User.find(params[:user_id])
  end
  
  # ログイン済みのユーザーか確認します。
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
  
  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
  
  # システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end
  
  # 管理者は勤怠画面と編集の権限はありません。
  def no_authority_admin
    if current_user.admin?
      flash[:danger] = "権限がありません。"
      redirect_to root_url
    end
  end


  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date #before_actionとして実行する
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] 
  
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
                  
    unless one_month.count == @attendances.count# それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do
             one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  
  rescue ActiveRecord::RecordInvalid 
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end