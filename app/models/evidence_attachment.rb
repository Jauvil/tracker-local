# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class EvidenceAttachment < ApplicationRecord
  # Access Control
  # using_access_control

  # Callbacks

  # Relationships
  belongs_to              :evidence, counter_cache: true
  has_attached_file       :attachment

  # Validations
  validates_presence_of(
    :name,
    :attachment_file_name,
    :attachment_content_type,
    :attachment_file_size
  )

  #Rails 4 requires either a file_type validation 
  #or explicit instructions not to validate. 
  do_not_validate_attachment_file_type :attachment

  # Other Methods
end
