# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class AttendanceType < ActiveRecord::Base
  belongs_to :school
  has_many :attendances
  # attr_accessible :description, :active

  validates :description, presence: {message: I18n.translate('errors.cant_be_blank')}
  validates :school, presence: {message: I18n.translate('errors.cant_be_blank')}

  # scopes
  scope :active_attendance_types, -> { where(active: true)}
  scope :all_attendance_types, -> { where(active: [true, false])}



  # returns all valid Attendance Types for an attendance record.
  # - it will include a deactivated record matching the ID passed.
  # - this is for select boxes so the attendance record can show deactivated items (if it was saved before deactivation).
  def self.valid_options(school_id, id)
    active_recs = AttendanceType.where(school_id: school_id, active: true).or(AttendanceType.where(:id => id, :active => false))
    return active_recs
  end


end
