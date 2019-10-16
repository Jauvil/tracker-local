# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class TeachingAssignment < ApplicationRecord
  # Access Control
  # using_access_control

  # Relationships
  belongs_to            :teacher
  belongs_to            :section

  # Validations
  validates_presence_of :teacher_id

  # Other Definitions
end
