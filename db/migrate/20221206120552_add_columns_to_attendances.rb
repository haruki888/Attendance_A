class AddColumnsToAttendances < ActiveRecord::Migration[5.1]
  def change
    
    #1ヶ月勤怠申請
    add_column :attendances, :one_month_request_superior, :string
    add_column :attendances, :one_month_request_status, :string
    add_column :attendances, :one_month_approval_superior, :string
    add_column :attendances, :one_month_approval_status, :string
    
    #勤怠変更
    add_column :attendances, :change_check, :boolean, default: false                  #勤怠変更確認チェック
    add_column :attendances, :request_change_superior, :string                        #勤怠変更申請
    add_column :attendances, :request_change_status, :string                          #勤怠変更申請状態
    add_column :attendances, :before_started_at, :datetime                            #変更前出勤時間
    add_column :attendances, :before_finished_at, :datetime                           #変更前退勤時間
    add_column :attendances, :after_started_at, :datetime                             #変更後出勤時間         
    add_column :attendances, :after_finished_at, :datetime                            #変更後退勤時間
    
   
    #残業申請
    add_column :attendances, :request_overtime_superior, :string                      #残業申請
    add_column :attendances, :request_overtime_status, :string                        #残業申請状態
    add_column :attendances, :next_day, :boolean, default: false                      #次の日
    add_column :attendances, :overtime_next_day, :boolean, default: false             #残業時間次の日
    add_column :attendances, :overtime_check, :boolean, default: false                #残業確認チェック
    add_column :attendances, :work_description, :string                               #業務処理内容
  end
end
