module UsersHelper
  
  # 出勤時間と退勤時間を受け取り、実際の労働時間を秒単位で在社時間を計算して返します。
  def working_times(start, finish, next_day)
    if next_day
      format("%.2f", (((finish- start) / 60) / 60.0) + 24)
    else
      format("%.2f", (((finish - start) / 60) / 60.0))
    end
  end

  def working_overtimes(scheduled_end_time, designated_work_end_time, next_day)
    if scheduled_end_time.present? && designated_work_end_time.present?  #undefined method `-' for nil:NilClassを解決
      if next_day
        format("%.2f", ((scheduled_end_time.hour - designated_work_end_time.hour) + (scheduled_end_time.min - designated_work_end_time.min) / 60) + 24)
      elsif
        format("%.2f", ((scheduled_end_time.hour - designated_work_end_time.hour) + (scheduled_end_time.min - designated_work_end_time.min) / 60))
      end
    end
  end
    
  # 勤怠基本情報を指定のフォーマットで返します。
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
end
