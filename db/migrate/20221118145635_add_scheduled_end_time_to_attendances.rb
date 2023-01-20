class AddScheduledEndTimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :scheduled_end_time, :datetime#終了予定時間
  end
end

#終了予定時間