class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception          #CSRF対策(クロスサイトリクエストフォージェリ)
  include SessionsHelper                         #サイトに攻撃用のコードを仕込むことで、アクセスした
                                                  #ユーザーに対し意図しない操作を行わせる攻撃のこと
  $days_of_the_week = %w{日 月 火 水 木 金 土}   #<%= csrf_meta_tags %> applicaiton.html.erb.rbとセット  
#リテラル表記 ↑ ["日", "月", "火", "水", "木", "金", "土"]の配列と同じように使えます。
# ページ出力前に1ヶ月分のデータの存在を確認・セットします。

  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
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

def set_one_month
  @first_day = params[:date].nil? ?
  Date.current.beginning_of_month : params[:date].to_date #before_actionとして実行する
  @last_day = @first_day.end_of_month
  one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
  # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
  @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
                #Attendanceモデルは1対多の関係なので、attendancesとなる仕組み。
  unless one_month.count == @attendances.count# それぞれの件数（日数）が一致するか評価します。
    ActiveRecord::Base.transaction do # トランザクションを開始します
    # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
      one_month.each { |day| @user.attendances.create!(worked_on: day) }
    end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
  end
  
  rescue ActiveRecord::RecordInvalid #トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end