class AttendancesController < ApplicationController
  protect_from_forgery

  before_action :set_user, only: %i[edit_one_month update_one_month edit_request_change update_request_change  update_one_month_apply edit_overtime_approval]
  before_action :set_user_id, only: %i[update edit_request_change update_request_change edit_request_overtime update_request_overtime edit_overtime_approval update_overtime_approval edit_one_month_approval update_one_month_approval edit_fix_log]
  before_action :set_attendance_id, only: %i[update edit_request_overtime update_request_overtime edit_overtime_approval]
  before_action :logged_in_user, only: %i[update edit_one_month edit_fix_log]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :admin_access, only: %i[edit_one_month update_one_month edit_fix_log]
  before_action :correct_user, only: %i[edit_fix_log]
  before_action :set_one_month, only: %i[edit_one_month edit_fix_log update_one_month_apply]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直して下さい。"


  # 出退勤打刻
  def update
    attendance = Attendance.find(params[:id])
      if attendance.started_at.nil?
        if attendance.update(started_at: Time.current.change(sec: 0))
          flash[:info] = "おはようございます！"
        else
          flash[:danger] = UPDATE_ERROR_MSG
        end
      else attendance.finished_at.nil?
        if attendance.update(finished_at: Time.current.change(sec: 0))
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
        if item[:request_change_superior].present?
          if item[:after_started_at].present? && item[:after_finished_at].blank?
            flash[:danger] = "退社時間を入力してください。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          elsif item[:after_started_at].blank? && item[:after_finished_at].present?
            flash[:danger] = "出勤時間を入力してください。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          elsif item[:after_started_at].blank? && item[:after_finished_at].blank?
            flash[:danger] = "出勤時間と退勤時間を入力してください。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          elsif item[:next_day] == "0" && item[:after_started_at].present? && item[:after_finished_at].present? && item[:after_started_at] > item[:after_finished_at]
            flash[:danger] = "退社時間が出勤時間よりも早いです。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          elsif item[:note].blank?
            flash[:danger] = "備考欄に理由を入力してください。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end
          attendance = Attendance.find(id)
          item[:request_change_status] = "申請中" #更新後に勤怠画面（指示者確認欄に表示）
          request_count += 1
          attendance.update!(item)
        end
      end
      if request_count > 0
        flash[:success] = "勤怠申請を#{request_count}件送りました。"
        redirect_to user_url(date: params[:date]) and return
      else
        flash[:danger] = "未入力箇所があります。"	
        redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "勤怠情報に不備があります。再度確認してください。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
  end


  #勤怠変更申請お知らせモーダル
  def edit_request_change
    @attendances = Attendance.where(request_change_superior: @user.name, request_change_status: "申請中").order(:worked_on).group_by(&:user_id)
  end
  #検索結果をworked_onカラムの値でソートし、user_idでグループ化
  # &はブロックの省略形式
  
  # 勤怠変更申請モーダル承認
  def update_request_change
    request_count = 0
    request_change_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:change_check] == "1"
        if item[:request_change_status] == "承認"
          if item[:before_started_at].present? && item[:before_finished_at].present?
            item[:before_started_at] = attendance.started_at
            item[:before_finished_at] = attendance.finished_at
            item[:started_at] = attendance.after_started_at if attendance.after_started_at.present?
            item[:finished_at] = attendance.after_finished_at if attendance.after_finished_at.present?
          end
        elsif item[:request_change_status] == "なし"
          item[:request_change_status] = "なし" #更新後に勤怠画面（指示者確認欄に表示）
          item[:note] = nil
          attendance.after_started_at = nil if attendance.after_started_at.present?
          attendance.after_finished_at = nil if attendance.after_finished_at.present?
        elsif item[:request_change_status] == "申請中"
          flash[:danger] = "指示者確認㊞を申請中以外で選択してください。"
          redirect_to user_url(@user) and return
        end
        attendance.update(item)
        request_count += 1
      elsif item[:change_check] == "0"
        if item[:request_change_status] == "申請中"
          flash[:danger] = "指示者確認㊞を申請中以外を選択し変更欄にチェックを入れてください。"
          redirect_to user_url(@user) and return
        else
          flash[:danger] = "変更欄にチェックを入れてください。"
          redirect_to user_url(@user) and return
        end
      end
    end
    if request_count > 0
      flash[:success] = "勤怠変更の申請結果を#{request_count}件送信しました."
    else
      flash[:danger] = "勤怠変更申請の承認が不十分です."
    end
    redirect_to user_url(@user)
  end


  #残業申請モーダル
  def edit_request_overtime
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @attendances = Attendance.where(request_overtime_superior: @user.name, request_overtime_status: "申請中").order(:worked_on).group_by(&:user_id)
  end

  #残業申請モーダル更新
  def update_request_overtime
    if request_overtime_params[:request_overtime_superior].blank? || request_overtime_params[:scheduled_end_time].blank? || request_overtime_params[:work_description].blank? || request_overtime_params[:overtime_next_day].blank?
      flash[:danger] = "未入力欄があります."
      redirect_to user_url(@user) and return
    elsif @attendance.started_at.nil? && @attendance.finished_at.nil?
      flash[:danger] = "無勤では残業申請できません。"
      redirect_to user_url(@user) and return
    else
      if @attendance.update(request_overtime_params)
        params[:attendance][:request_overtime_status] = "申請中"
        flash[:success] = "#{@user.name}さんの残業を申請しました."
      else
        flash[:danger] = "残業の申請に不備があります。再度確認してください."
      end
    end
    redirect_to user_url(@user) and return
  end


  #残業申請通知モーダル
  def edit_overtime_approval
    @attendances = Attendance.where(request_overtime_superior: @user.name, request_overtime_status: "申請中").order(:worked_on).group_by(&:user_id)
  end

  #残業申請通知モーダル承認更新
  def update_overtime_approval
    request_count = 0
    overtime_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:overtime_check] == "1"
        if item[:request_overtime_status] == "承認"
          if item[:designated_work_end_time].present? && item[:scheduled_end_time] > item[:designated_work_end_time]
            flash[:danger] = "申請の終了時間が指示の終了時間を超えています。"
            redirect_to user_url(@user) and return
          end
        elsif item[:request_overtime_status] == "否認"
          if item[:designated_work_end_time].present? && item[:scheduled_end_time] < item[:designated_work_end_time]
            flash[:danger] = "申請の終了時間が指示の終了時間より早いです。"
            redirect_to user_url(@user) and return
          end
        elsif item[:request_overtime_status] == "申請中"
          flash[:danger] = "指示者確認欄㊞が申請中になっています。"
          redirect_to user_url(@user) and return
        elsif item[:request_overtime_status] == "なし"
          item[:request_overtime_status] = "なし" # 更新後に勤怠画面（指示者確認欄に表示）
          item[:scheduled_end_time] = nil if item[:scheduled_end_time].present?
          item[:designated_work_end_time] = nil if item[:designated_work_end_time].present?
          item[:work_description] = nil if item[:work_description].present?
          item[:overtime_next_day] = nil if item[:overtime_next_day].present?
        end
      elsif item[:overtime_check] == "0"
        if item[:request_overtime_status] == "申請中"
          flash[:danger] = "変更チェックを入れ、指示者確認欄を申請中以外で選択してください。"
          redirect_to user_url(@user) and return
        elsif 
          flash[:danger] = "変更チェックを入れてください。"
          redirect_to user_url(@user) and return
        end
      end
      request_count += 1
      attendance.update(item)
    end
    if request_count > 0
      flash[:success] = "残業申請結果を#{request_count}件送信しました。"
    else
      flash[:danger] = "更新する残業申請がありません。"
    end
    redirect_to user_url(@user)
  end

  
  def edit_one_month_apply
    @attendances = Attendance.where(one_month_apply_superior: @user.name, one_month_apply_status: "申請中")
  end

  
  #1ヶ月勤怠申請
  def update_one_month_apply
    @attendance = @user.attendances.find_by(worked_on: @first_day)      
    if one_month_apply_params[:one_month_apply_superior].present?
      flash[:success] = "所属長承認申請が送信されました。"
    elsif one_month_apply_params[:one_month_apply_superior].blank?
      one_month_apply_params[:one_month_apply_superior] = "上長を選択して下さい"
      flash[:danger] = "所属長を選択して下さい。"
      redirect_to user_url(@user) and return
    end
      @attendance.update(one_month_apply_params)
      one_month_apply_params[:one_month_apply_status] = "申請中"
      redirect_to user_url(@user) and return
  end

  #1ヶ月勤怠申請通知モーダル
  def edit_one_month_approval
    @attendances = Attendance.where(one_month_apply_superior: @user.name, one_month_apply_status: "申請中").order(worked_on: :asc).group_by(&:user_id)
  end

  #1ヶ月勤怠申請承認
  def update_one_month_approval
   #debugger
    request_count = 0
    one_month_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:approval_check] == '1'
        if item[:one_month_approval_status] == "申請中"
          flash[:danger] = "指示者確認㊞は申請中以外で選択して下さい。"
          redirect_to user_url(@user) and return
        end
      elsif item[:approval_check] == '0'
        flash[:danger] = "変更にチェックして下さい。"
        redirect_to user_url(@user) and return
      end
      item[:one_month_apply_status] = nil
      request_count += 1
      attendance.update(item)
    end
    if request_count > 0
      flash[:success] = "1ヶ月申請結果を#{request_count}件送信しました。"
      redirect_to user_url(@user)
    else
      flash[:danger] = "1ヶ月申請承認が不十分です。"
      redirect_to user_url(@user) and return
    end
  end


  def edit_fix_log
    if params["select_year(1i)"].present? && params["select_month(2i)"].present?
      @first_day = Date.parse("#{params["select_year(1i)"]}/#{params["select_month(2i)"]}/1")
      # parseメソッドは、引数でJSON形式の文字列をRubyのオブジェクトに変換して返すメソッド
    else
      @first_day = nil
    end

    if params[:commit] == "リセット"
      @attendances = []
    elsif @first_day.present?
      @attendances = @user.attendances.where(request_change_status: "承認", worked_on: @first_day..@first_day.end_of_month).order(:worked_on)
    else
      @attendances = nil
    end
  end


  private
  
  
  
  #1ヶ月分の勤怠情報
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :after_started_at, :after_finished_at, :note, :next_day, :request_change_superior, :request_change_status])[:attendances]
  end
  
  #1ヶ月の勤怠申請
  def one_month_apply_params
    params.require(:attendance).permit(:one_month_apply_superior, :one_month_apply_status)
  end
   
  #1ヶ月の勤怠承認
  def one_month_approval_params
    params.require(:user).permit(attendances: [:one_month_approval_status, :approval_check, :one_month_apply_superior])[:attendances]
  end

  #勤怠変更申請
  def request_change_params
    params.require(:user).permit(attendances: [:before_started_at, :before_finished_at, :after_started_at, :after_finished_at, :request_change_status, :change_check, :note, :id])[:attendances]
  end

  #残業申請
  def request_overtime_params
    params.require(:attendance).permit(:scheduled_end_time, :overtime_next_day, :work_description, :request_overtime_superior, :request_overtime_status, :overtime_check, :user_id)
  end

  #残業申請承認
  def overtime_approval_params
    params.require(:user).permit(attendances: [:overtime_check, :request_overtime_status, :designated_work_end_time, :user_id])[:attendances]
  end
end