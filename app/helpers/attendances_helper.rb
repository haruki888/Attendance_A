module AttendancesHelper  #ViewをDRY（Don’t Repeat Yourself）に作る
  
  def attendance_state(attendance)
      # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    #どれにも当てはまらなかった場合はfalseを返します。
    return false
  end
  
   # 出勤時間と退勤時間をn受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  def working_overtime(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0) - (60.0*8))
  end
  
   # 不正な値があるか確認する
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        break
      end
    end
    return attendances
  end
end 

