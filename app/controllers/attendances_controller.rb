class AttendancesController < ApplicationController
  protect_from_forgery
  include UsersHelper
  
  before_action :set_user, only: %i[edit_one_month update_one_month edit_request_change update_request_change]
  before_action :set_user_id, only: %i[update edit_request_change update_request_change edit_request_overtime update_request_overtime edit_overtime_approval update_overtime_approval edit_fix_log]
  before_action :set_attendance_id, only: %i[update edit_request_overtime update_request_overtime]
  before_action :logged_in_user, only: %i[update edit_one_month]
  before_action :admin_or_correct_user, only: %i[update edit_one_month update_one_month]
  before_action :admin_limit, only: %i[edit_one_month]
  before_action :set_one_month, only: %i[edit_one_month edit_fix_log]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直して下さい。"
  
  # 出退勤打刻
  def update
    attendance = Attendance.find(params[:id])
      if attendance.started_at.nil?
        if attendance.update(started_at: Time.current.floor_to(15.minutes))
          flash[:info] = "おはようございます！"
        else
          flash[:danger] = UPDATE_ERROR_MSG
        end
      else attendance.finished_at.nil?
        if attendance.update(finished_at: Time.current.floor_to(15.minutes))
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
  
  # 勤怠編集更新
  def update_one_month
    request_count = 0
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:request_change_superior].present? && item[:note].present?
          if item[:after_started_at].present? && item[:after_finished_at].blank?
            flash[:danger] = '退社時間を入力してください。'
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end  
          if item[:after_started_at].blank? && item[:after_finished_at].present?
            flash[:danger] = '出勤時間を入力してください。'
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end
          if item[:after_started_at] > item[:after_finished_at] && item[:next_day] == false
            flash[:danger] = '出勤時間が退勤時間より後になっています。'
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end
          item[:request_change_status] = "申請中"
          request_count += 1
          attendance.update!(item)
        end
      end
      if request_count > 0
        flash[:success] = "勤怠申請を#{request_count}件送りました。"
        redirect_to user_url(date: params[:date]) and return
      else
        flash[:danger] = "未入力箇所があります。"	
        redirect_to attendances_edit_one_month_user_url(date: params[:date])	
        return
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "勤怠情報に不備があります。再度確認してください。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
    return
  end


  #勤怠変更申請モーダル
  def edit_request_change
    @attendances = Attendance.where(request_change_superior: @user.name, request_change_status: "申請中").order(:worked_on).group_by(&:user_id)
  end
  #検索結果をworked_onカラムの値でソートし、user_idでグループ化
  
  
  #勤怠変更申請モーダル更新
  def update_request_change
    request_count = 0
    request_change_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:change_check] == 1    
        if item[:request_change_status] == "承認"
          attendance.before_started_at = attendance.started_at      #変更後出勤時間
          attendance.before_finished_at = attendance.finished_at    #変更後退勤時間
          item[:started_at] = attendance.after_started_at           #変更後出勤時間
          item[:finished_at] = attendance.after_finished_at         #変更後退勤時間

        elsif item[:request_change_status] == "否認"
          item[:started_at] == nil if item[:started_at].present?
          item[:finished_at] == nil if item[:finished_at].present?
          item[:note] == nil
          
        elsif item[:request_change_status] == 'なし'
          attendance.after_started_at == nil if attendance.after_started_at.present?
          attendance.after_finished_at == nil if attendance.after_finished_at.present?
          item[:note] == nil
        end
        
      elsif item[:change_check] == 0
        flash[:danger] = '変更チェックを入力してください。'
        redirect_to user_url(@user)
        return
      end
      request_count += 1
      attendance.update(item)
    end
    if request_count > 0
      flash[:success] = "勤怠変更の申請結果を#{request_count}件送信されました。"
    else
      flash[:danger] = '勤怠変更の申請が不十分です。'
    end
    redirect_to user_url(@user) and return
  end
  
  
  #残業申請モーダル
  def edit_request_overtime
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @attendance = Attendance.find(params[:id])
    @attendances = Attendance.where(request_overtime_superior: @user.name, request_overtime_status: "申請中").order(:worked_on).group_by(&:user_id)
  end
  
  
  #残業申請モーダル
  def update_request_overtime
      @attendance = Attendance.find(params[:id])
      if request_overtime_params[:request_overtime_superior].blank? || request_overtime_params[:scheduled_end_time].blank? || request_overtime_params[:work_description].blank? || request_overtime_params[:overtime_next_day].blank?
        flash[:danger] = "未入力欄があります。"
        redirect_to user_url(@user) and return
      end
      if @attendance.update(request_overtime_params)
        params[:attendance][:request_overtime_status] = "申請中"
        flash[:success] = "#{@user.name}さんの残業を申請しました。"
      else
        flash[:danger] = "残業の申請に不備があります。再度確認してください。"
      end
      redirect_to user_url(@user) and return
  end 
   
     
  #残業申請通知モーダル
  def edit_overtime_approval
    @user = User.find(params[:id])
    @attendance = Attendance.find(params[:id])
    @attendances = Attendance.where(request_overtime_superior: @user.name, request_overtime_status: "申請中").order(:worked_on).group_by(&:user_id)
  end
  
  #残業申請通知承認モーダル更新
  def update_overtime_approval
    overtime_approval_params.each do |id, item|
      attendance = Attendance.find(id)
        if item[:overtime_check] == 1
          if item[:request_overtime_status] == "承認"
            item[:scheduled_end_time] > item[:designated_work_end_time] if item[:designated_work_end_time].present?
          elsif item[:request_overtime_status] == "否認"
            item[:scheduled_end_time] < item[:designated_work_end_time] if item[:designated_work_end_time].present?
          elsif item[:request_overtime_status] == "なし"
            item[:scheduled_end_time] = nil
            item[:designated_work_end_time] = nil
            item[:work_description] = nil
            item[:request_overtime_status] = nil
          end
        elsif item[:overtime_check] == 0
          flash[:danger] = '変更欄にチェックを入力してください。'
          redirect_to user_url(@user) and return
        end
        attendance.update(item)
        flash[:success] = '残業申請結果を送信しました。'
        redirect_to user_url(@user) and return
    end
  end
          
  def edit_fix_log
    if params["select_year(1i)"].present? && params["select_month(2i)"].present?
      @selected_date = Date.parse("#{params["select_year(1i)"]}/#{params["select_month(2i)"]}/1")
    else
      @selected_date = nil
    end
  
    if params[:commit] == "リセット"
      @attendances = []
    elsif @selected_date.present?
      @attendances = @user.attendances.where(request_change_status: "承認", worked_on: @selected_date.beginning_of_month..@selected_date.end_of_month).order(:worked_on)
    else
      @attendances = @user.attendances.where(request_change_status: "承認").order(:worked_on)
    end
  end

  
  private
  
  
  
  # 1ヶ月分の勤怠情報を扱います
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :after_started_at, :after_finished_at, :note, :next_day, :request_change_superior, :request_change_status])[:attendances]
  end
  
  #勤怠変更申請
  def request_change_params
    params.require(:user).permit(attendances: [:after_started_at, :after_finished_at, :request_change_status, :change_check, :note, :user_id])[:attendances]
  end
  
  #残業申請
  def request_overtime_params
    params.require(:attendance).permit(:scheduled_end_time, :overtime_next_day, :work_description, :request_overtime_superior, :request_overtime_status, :overtime_check, :user_id)
  end
  
  #残業申請承認
  def overtime_approval_params
    params.require(:user).permit(attendances: [:overtime_check, :request_overtime_status, :designated_work_end_time, :user_id])[:attendances]
  end
  
  def import
    User.import(params[:file])
    redirect_to root_url
  end
end