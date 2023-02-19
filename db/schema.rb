# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20230131123847) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"                                                      #日時取扱い
    t.datetime "started_at"                                                 #出勤時刻 
    t.datetime "finished_at"                                                #退勤時刻
    t.datetime "work_start_time"                                            #勤怠開始時間
    t.datetime "work_end_time"                                              #勤怠終了時間
    t.string "note"                                                         #備考
    t.integer "user_id"                                                     #ユーザーを紐づける
    t.datetime "created_at", null: false                                    #作成日時
    t.datetime "updated_at", null: false                                    #更新日時
    t.datetime "scheduled_end_time"                                         #終了予定時間
    t.string "one_month_request_superior"                                   #1ヶ月勤怠申請
    t.string "one_month_request_status"                                     #1ヶ月勤怠申請状態
    t.string "one_month_approval_superior"                                  #1ヶ月勤怠承認申請
    t.string "one_month_approval_status"                                    #1ヶ月勤怠承認状態
    t.boolean "change_check", default: false                                #変更確認チェック
    t.string "request_change_superior"                                      #勤怠変更申請
    t.string "request_change_status"                                        #勤怠変更状態
    t.datetime "before_started_at"                                          #出勤前
    t.datetime "before_finished_at"                                         #退勤前
    t.datetime "after_started_at"                                           #出勤後
    t.datetime "after_finished_at"                                          #退勤後
    t.string "request_overtime_superior"                                    #残業申請
    t.string "request_overtime_status"                                      #残業申請状態
    t.boolean "next_day", default: false                                    #次の日
    t.boolean "overtime_next_day", default: false, null: false              #次の日の残業時間
    t.boolean "overtime_check", default: false                              #残業確認チェック
    t.string "work_description"                                             #業務内容   
    t.index ["user_id"], name: "index_attendances_on_user_id"               #
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_number"                                                 #拠点番号
    t.string "base_name"                                                    #拠点名
    t.string "base_type"                                                    #拠点種類
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"                                              #暗号化されたパスワード
    t.string "remember_digest"                                              #ハッシュ化された記憶トークン
    t.boolean "admin", default: false
    t.datetime "basic_work_time", default: "2023-02-07 23:00:00"            #指定労勤務時間
    t.datetime "work_time", default: "2023-02-07 22:30:00"                  #勤務時間
    t.boolean "superior", default: false                                    #上長
    t.integer "employee_number", default: 0                                 #社員番号
    t.string "uid"                                                          #ユーザーID
    t.datetime "designated_work_start_time", default: "2023-02-07 23:30:00" #指定勤務開始時間
    t.datetime "designated_work_end_time", default: "2023-02-08 08:30:00"   #指定勤務終了時間
    t.string "affiliation"                                                  #所属
    t.index ["email"], name: "index_users_on_email", unique: true           #
  end
end
