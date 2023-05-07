class AttendancesController < ApplicationController
  
  include AttendancesHelper
  before_action :set_user, only: %i[edit_one_month update_one_month]
  before_action :set_user_id, only: %i[update]
  before_action :set_attendance_id, only: %i[update edit_request_overtime update_request_overtime]
  before_action :logged_in_user, only: %i[update edit_one_month]
  before_action :admin_or_correct_user, only: %i[update edit_one_month update_one_month]
  before_action :admin_limit, only: :edit_one_month
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直して下さい。"
   
    
  def update
    # 出勤時間が未登録であることを判定します。
      if @attendance.started_at.nil?
        if @attendance.update_attributes(started_at: Time.current.floor_to(15.minutes))
          flash[:info] = "おはようございます！"
        else
          flash[:danger] = UPDATE_ERROR_MSG
        end
      elsif @attendance.finished_at.nil?
        if @attendance.update_attributes(finished_at: Time.current.floor_to(15.minutes))
          flash[:info] = "お疲れ様でした。"
        else
          flash[:danger] = UPDATE_ERROR_MSG
        end
      end
      redirect_to @user
  end
  
  def edit_one_month
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  # 勤怠変更承認
  def update_one_month
    request_count = 0
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
       if item[:request_change_superior].present?
        if item[:after_started_at].blank? && item[:after_finished_at].present?
          flash[:danger] = "出勤時間を入力して下さい。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        elsif item[:after_started_at].present? && item[:after_finished_at].blank?
          flash[:danger] = "退勤時間を入力して下さい。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        end
        #redirect_toは1回指定したアクションを実行して、そのアクションに対応したビューを表示
        #returnには「指定した式の値を返り値として返す」と「メソッドの処理を終了させる」という2つの機能がある
        #renderはアクションを実行せずにビューファイルを表示 
          attendance = Attendance.find(id)
          attendance.request_change_status = "申請中"
          request_count += 1
          attendance.update_attributes!(item)#update_attributes  → falseを返す
        end                                  #update_attributes! → 例外(validation)を投げる
      end
      if request_count > 0
        flash[:success] = "勤怠変更を#{request_count}件申請しました。"
        redirect_to user_url(date: params[:date]) and return
      end
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "勤怠情報に不備があります。再度確認してください。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
    end
  end

  #残業申請モーダル
  def edit_request_overtime
    @attendance = Attendance.find(params[:id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  #残業申請更新モーダル
  def update_request_overtime
    if request_overtime_params[:scheduled_end_time].blank? ||
       request_overtime_params[:work_description].blank? ||
       request_overtime_params[:request_overtime_supeior].blank?
       flash[:danger] = "終了予定時間、業務内容、所属長の選択がありません。"
    else
       request_overtime_params[:scheduled_end_time].present? &&
       request_overtime_params[:work_description].present? &&
       request_overtime_params[:request_overtime_superior].present?
       params[:request_overtime_status][:attendance] = "申請中"
         if @attendance.update(requet_overtime_params)
            flash[:succsess] = "#{@user.name}さんの残業を申請しました。"
         end
    end
  end

      
       
     
  #残業申請通知モーダル
  def edit_overtime_approval
    @attendances = Attendance.where(one_month_request_superior: @user.name, one_month_request_status: "申請中").order(:worked_on).group_by(&:user_id)
  end
  
  # 勤怠ログ
  def edit_log
    if params[:worked_on].present?
      first_day = DateTime.parse(params[:worked_on] + "-" + "01") # 文字列で取得した日付に文字列の01を加えてdatetime型に型変換し月初日をセット
      last_day = first_day.end_of_month # 月末日を取得
      # Attendanceテーブルからworked_onの日付順で整列し、現在ログインしているユーザ、承認のものを取得し、paramsで取得した月に合致するものをセット
      @approval_change_attendance_requests = Attendance.order(:worked_on).where(user_id: current_user, edit_attendance_request_status: "承認").where(worked_on: first_day..last_day) 
      if @approval_change_attendance_requests.size > 0
        render
      else
        flash.now[:danger] = "選択月の勤怠編集ログはありません。"
      end
    end
  end

  
  
  private
  
  
  
  # 1ヶ月分の勤怠情報を扱います
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :next_day, :request_change_superior, :request_change_status])[:attendances]
  end
  
  #残業申請
  def request_overtime_params
    params.require(:attendance).permit([:worked_on, :scheduled_end_time, :overtime_next_day, :work_description, :request_overtime_superior, :request_overtime_status])[:attendances]
  end
  
 
  def import
    User.import(params[:file])
    redirect_to root_url
  end
end
