class AddDesignatedWorkToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :designated_work_start_time, :datetime, default: Time.current.change(hour: 8, min: 30, sec: 0)#指定勤務開始時間
    add_column :users, :designated_work_end_time, :datetime, default: Time.current.change(hour: 17, min: 30, sec: 0)#指定勤務終了時間
  end
end
