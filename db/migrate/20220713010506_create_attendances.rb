class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :work_start_time
      t.datetime :work_end_time
      t.string :note
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
