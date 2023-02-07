class AttendancesController < ApplicationController
  
  include AttendancesHelper
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :set_user_id, only: [:update, :edit_request_overtime, :update_request_overtime, :edit_overtime_approval, :update_overtime_approval, :edit_one_month_approval, :update_one_month_approval, :edit_request_change, :update_request_change]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :show, :edit_one_month, :update_one_month]
  before_action :no_authority_admin, only: :edit_one_month
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直して下さい。"
  
  # 出退勤ボタンの勤務登録
  def update
    @attendance = Attendance.includes(:user)	
    # 出勤時間が未登録であることを判定します。
      if @attendance.started_at.nil?
        if @attendance.update_attributes(started_at: Time.current.floor_to(15.minutes))#15分単位で丸める
          flash[:info] = "おはようございます！"
        else
          flash[:danger] = UPDATE_ERROR_MSG
        end
      elsif @attendance.finished_at.nil?
        if @attendance.update_attributes(finished_at: Time.current.floor_to(15.minutes))#15分単位で丸める
          flash[:info] = "お疲れ様でした。"
        else
          flash[:danger] = UPDATE_ERROR_MSG
        end
      end
      redirect_to @user
  end
  
  # 勤怠修正ページ
  def edit_one_month
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  # 勤怠変更承認
  def update_one_month
    count_number = 0
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        if item[:request_change_superior].present? && item[:note].present?
          if item[:started_at].present? && item[:finished_at].present?
            flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
            redirect_to user_url(date: params[:date]) and return
          else
            flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end
          attendance = Attendance.find(id)
          count_number += 1
          attendance.attendance_request_change_status = "申請中"
          attendance.update_attributes!(item)#update_attributes  → falseを返す
        end                                  #update_attributes! → 例外(validation)を投げる
      end                                       
      if count_number > 0
        flash[:success] = "勤怠変更を#{count_number}件申請しました。"
        redirect_to user_url(date: params[:date]) and return
      else
        flash[:info] = "勤怠編集はありません。"
        redirect_to user_url(date: params[:date]) and return
      end
    end
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
    end

  #残業申請
  def edit_request_overtime
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  #残業申請更新
  def update_request_overtime
    if request_overtime_params[:scheduled_end_time].blank? ||
       request_overtime_params[:work_description].blank? ||
       repuest_overtime_params[:request_overtime_superior].blank?
         flash[:danger] = "未入力欄があります。"
    else
      if request_overtime_params[:scheduled_end_time].present? &&
         request_overtime_params[:business_content].present? && 
         repuest_overtime_params[:request_overtime_superior].present?
           params[:attendance][:request_overtime_status] = "申請中"
           @attendance.update(requeset_overtime_params)
           flash[:success] = "残業申請しました。"
         if overtime_params[:scheduled_end_time].present?
           @attendance.update_attributes(overtime_params)
           flash[:info] = "残業申請しました。"
         end
      else
        flash[:danger] = "残業申請をやり直して下さい。"
      end
      redirect_to @user
    end
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
  
  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
  end
  
  #残業申請
  def request_overtime_params
    params.require(:attendance).permit(:scheduled_end_time, :next_day, :business_content, :request_overtime_superior, :request_overtime_status)
  end  
  # beforeフィルター
  
  
  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end
  
  def logged(admin_user)
  end
    
  def import
    User.import(params[:file])
    redirect_to root_url
  end
end
