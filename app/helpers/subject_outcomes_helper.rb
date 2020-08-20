# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
module SubjectOutcomesHelper

  include ApplicationHelper

  def lo_get_model_school(params)
    # get school from school_id parameter if there
    @school = (params['school_id'].present?) ? School.find(params['school_id']) : nil
    # make sure school is model school, else look up the model school
    if @school.blank? || @school.acronym != 'MOD'
      match_model_schools = School.where(acronym: 'MOD')
      if match_model_schools.count == 1
        @school = match_model_schools.first
      else
        @errors[:school] = 'ERROR: Missing Model School'
        raise @errors[:school]
      end
    end
    if @school.school_year_id.blank?
      @errors[:school] = 'ERROR: Missing school year for Model School'
      raise @errors[:school]
    else
      @school_year = @school.school_year
      session[:school_context] = @school.id
      set_current_school
    end
    # Note: Curriculum subjects normally contain more than one grade
    # Note: Curriculum has Grade Bands, that may include more than one grade (e.g. High School)
    if !@school.has_flag?(School::GRADE_IN_SUBJECT_NAME)
      # This may be possible with Curriculum Grade Bands that match the school's grades???
      @errors[:school] = 'Error: Bulk Upload LO is for schools with grade in subject name only.'
      raise @errors[:school]
    else
      #  - then we must (later) confirm that the grade in the subject name matches the Curriculum Grade Band (1 grade?)
      #  - then we must (later) also match the Curriculum subject and grade band with the Tracker Subject
    end
    return @school
  end

end
