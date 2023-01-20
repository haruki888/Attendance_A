class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :current_user, only: [:edit, :update, :show]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show

  def index
    @users = User.paginate(page: params[:page])
  end
  
  def show
      @superiors = User.where(superior: true).where.not(id: @user.id)#一般ユーザーでなく上長を取得する。
      @worked_sum = @attendances.where.not(started_at: nil).count#出勤がない日以外を取得し、合計を出す。
      @overtime_sum = Attendance.where(request_overtime_superior: @user.name, request_overtime_status: "申請中").count#残業申請を上長に申請している日の合計を出す。
      @change_sum = Attendance.where(request_change_superior: @user.name, request_change_status: "申請中").count#勤怠変更時間を上長に申請している日の合計を出す。
      @one_month_sum = Attendance.where(one_month_approval_superior: @user.name, one_month_approval_status: "申請中").count#1ヶ月の勤怠申請している月を取得する
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)#直接にparams[:カラムの値]とならないのは、Railsがストロンパラメータという値を
    if @user.save               #安全に受け取る仕組みを採用しているから。
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報は更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def import
    if params[:file].blank?
      flash[:danger] = "CSVファイルが選択されていません。"
      rediect_to users_url
    else
      if User.import(params[:file])
        falsh[:success] = "CSVファイルのインポートに成功しました。"
      else
        flash[:danger] = "CSVファイルのインポートに失敗しました。"
      end
      redirect_to users_url
    end
  end
  
  private #user_paramsメソッドは、Usersコントローラーの内部でのみ実行されます。
          #Web経由で外部のユーザーが知る必要は無いため、次に記すようにRubyのprivateキーワードを用いて
          #外部からは使用できないようにします

          
  def user_params #Strong Parameters
    params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,
                                :password, :password_confirmation, :basic_work_time,
                                :designated_work_start_time, :designaed_work_end_time)
  end

  def basic_info_params
    params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,
                                :password, :password_confirmation, :basic_work_time,
                                :designated_work_start_time, :designaed_work_end_time)
  end

  #def search
     #Viewのformで取得したパラメータをモデルに渡す
    #@users = User.search(params[:search])
  #end
  
  def user_login_required
    unless logged_in? # ログインしていないとき
      store_location # ここでURLを一時保存！
      flash[:danger] = "ログインしてください" # フラッシュメッセージを表示
      redirect_to login_url # ログインページに強制的に送る
    end
  end
end