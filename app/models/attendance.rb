class Attendance < ApplicationRecord
  belongs_to :user
  attr_accessor :designated_work_end_time
  validates :worked_on, presence: true
  validates :note, length: {maximum: 50}
  require 'date' 
  
  #出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  
  #退勤時間が存在しない場合、出勤時間は無効
  #validate :started_at_is_invalid_without_a_finished_at
  
  #出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  
  #勤怠編集画面で、出勤時間より早い退勤時間は無効
  # validate :after_started_at_than_after_finished_at_fast_if_invalid
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, 'が必要です') if started_at.blank? && finished_at.present?
  end
  
  def started_at_is_invalid_without_a_finished_at
    errors.add(:finished_at, 'が必要です') if finished_at.blank? && started_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, 'より早い退勤時間は無効です') if started_at > finished_at
    end
  end

  # def after_started_at_than_after_finished_at_fast_if_invalid
  #   if after_started_at.present? && after_finished_at.present?
  #     errors.add(:after_started_at, 'より早い退勤時間は無効です') if after_started_at > after_finished_at
  #   end

  #勤怠一覧出力
  def self.to_csv
    attributes = %w[date started_at finished_at ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |attendance|
        csv << attributes.map{ |attr| attendance.send(attr) }
      end
    end
  end
end
