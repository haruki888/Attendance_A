class AddColumnsToAttendances < ActiveRecord::Migration[5.1]
  def change
    
    #1ヶ月勤怠申請
    add_column :attendances, :one_month_request_superior, :string
    add_column :attendances, :one_month_request_status, :string
    add_column :attendances, :one_month_approval_superior, :string
    add_column :attendances, :one_month_approval_status, :string
    
    #勤怠変更、確認申請
    add_column :attendances, :request_confirmation_superior, :string
    add_column :attendances, :request_change_superior, :string
    add_column :attendances, :request_change_status, :string
   
    #残業申請
    add_column :attendances, :request_overtime_superior, :string
    add_column :attendances, :request_overtime_status, :string
    add_column :attendances, :next_day, :boolean, default: false
    add_column :attendances, :overtime_next_day, :boolean, default: false, null: false
    add_column :attendances, :overtime_check, :boolean, default: false
    add_column :attendances, :work_description, :string #業務処理内容
  end
end
