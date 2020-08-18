# stem_egypt_model_subjects.rake
# to populate a server's disciplines and load model school with subjects
# to delete: $ bundle exec rake stem_egypt_model_subjects:populate
#

# NOTE: do not call tasks within tasks without changing the error handling to use 'raise' not 'next'

namespace :stem_egypt_model_subjects do
  desc "Create initial set of model school subjects."

  task populate: :environment do
    include Sso::Constants

    @subjects_disciplines = {
      'Advisory 1' => 'Administration',
      'Advisory 2' => 'Administration',
      'Library 1' => 'Administration',
      'Library 2' => 'Administration',
      'Library 3' => 'Administration',
      'Capstone 1s1' => 'Capstones',
      'Capstone 1s2' => 'Capstones',
      'Capstone 2s1' => 'Capstones',
      'Capstone 2s2' => 'Capstones',
      'Capstone 3s1' => 'Capstones',
      'Art 1' => 'Creative Arts',
      'Art 2' => 'Creative Arts',
      'Art 3' => 'Creative Arts',
      'Music 1' => 'Creative Arts',
      'Music 2' => 'Creative Arts',
      'Music 3' => 'Creative Arts',
      'Arabic 1' => 'Linguistics',
      'Arabic 2' => 'Linguistics',
      'Arabic 3' => 'Linguistics',
      'English 1' => 'Linguistics',
      'English 2' => 'Linguistics',
      'English 3' => 'Linguistics',
      'French 1' => 'Linguistics',
      'French 2' => 'Linguistics',
      'French 3' => 'Linguistics',
      'German 1' => 'Linguistics',
      'German 2' => 'Linguistics',
      'German 3' => 'Linguistics',
      'Math 1' => 'Mathematics',
      'Math 2' => 'Mathematics',
      'Math 3' => 'Mathematics',
      'Mechanics 1' => 'Mathematics',
      'Mechanics 2' => 'Mathematics',
      'Mechanics 3' => 'Mathematics',
      'Statistics 3' => 'Mathematics',
      'Physical Education Boys 1' => 'Personal Health',
      'Physical Education Boys 2' => 'Personal Health',
      'Physical Education Boys 3' => 'Personal Health',
      'Physical Education Girls 1' => 'Personal Health',
      'Physical Education Girls 2' => 'Personal Health',
      'Physical Education Girls 3' => 'Personal Health',
      'Biology 1' => 'Science',
      'Biology 2' => 'Science',
      'Biology 3' => 'Science',
      'Chemistry 1' => 'Science',
      'Chemistry 2' => 'Science',
      'Chemistry 3' => 'Science',
      'Earth Science 1' => 'Science',
      'Earth Science 2' => 'Science',
      'Earth Science 3' => 'Science',
      'Physics 1' => 'Science',
      'Physics 2' => 'Science',
      'Physics 3' => 'Science',
      'Citizenship 1' => 'Social and Life Sciences',
      'Citizenship 2' => 'Social and Life Sciences',
      'Citizenship 3' => 'Social and Life Sciences',
      'Home Economics 1' => 'Social and Life Sciences',
      'Home Economics 2' => 'Social and Life Sciences',
      'Home Economics 3' => 'Social and Life Sciences',
      'Social Studies 1' => 'Social and Life Sciences',
      'Computer Science 1' => 'Technology',
      'Computer Science 2' => 'Technology',
      'Computer Science 3' => 'Technology',
      'Earth-Space, Advanced Lab 3' => 'Technology',
      'Electronics, Advanced Lab 3' => 'Technology',
      'Hydraulics, Advanced Lab 3' => 'Technology',
      'Robotics, Advanced Lab 3' => 'Technology',
      'Fab Lab 1' => 'Technology',
      'Fab Lab 2' => 'Technology'
    }

    @count = 0
    count1 = 0
    count2 = 0

    user = user = User.where(system_administrator: true).last
    token = JWT.encode({email: user.email, code: 'egstem'}, secrets['json_api_key'])

    egstem_curr = Curriculum::Client.curriculums(token)['curriculums'].first
    @model_school = School.first
    @model_school.update(
      curr_tree_type_id: egstem_curr['id'], 
      curr_version_code: egstem_curr['version_code'],
      curriculum_code: egstem_curr['code']
    )

    curriculum_subjects = Curriculum::Client.subjects(token, @model_school.curr_tree_type_id)['subjects']
    count3 = 0
    @curriculum_subjects_hash = {}
    curriculum_subjects.each do |subject|
      subject['grade_bands'].each do |grade_band|
        if grade_band['min_grade'] == grade_band['max_grade']
          subject_name = "#{subject['versioned_name']['en']} #{grade_band['code']}"
          @curriculum_subjects_hash[subject_name] = subject
          count3 += 1
        end
      end
      subject['matched'] = false
    end
    puts "Curriculum Subjects Count: #{count3}"

    tracker_subjects = Subject.where(school_id: @model_school.id)
    puts "Tracker Subjects Count: #{Subject.where(school_id: @model_school.id).count}"
    tracker_subjects.each do |subject|
      matching_curriculum_subject = @curriculum_subjects_hash[subject.name]
      subject_matched = subject_matched?(matching_curriculum_subject, subject)
      if subject_matched
        if !matching_curriculum_subject['active']
          count1 += 1
          subject.update(active: false)
        end
        @curriculum_subjects_hash[subject.name]['matched'] = true
        count2 += 1
        # puts "Matched Tracker Subject: #{subject.name}"
      else
        count1 += 1
        subject.update(active: false)
        # puts "Mis-Matched Tracker Subject: #{subject.name}"
      end
    end

    @curriculum_subjects_hash.values.each do |subject|
      create_tracker_subjects(subject)
    end

    puts "Tracker Subjects Updated: #{count2}"    
    puts "Tracker Subjects Deactivated: #{count1}"
    puts "New Tracker Subjects Created: #{@count}"
    puts "New Total Tracker Subjects Count: #{Subject.where(school_id: @model_school.id).count}"
  end
end

### Helper Methods ***

def create_tracker_subjects(subject)
  subject['grade_bands'].each do |grade_band|
    if grade_band['min_grade'] == grade_band['max_grade']
      subject_name = "#{subject['versioned_name']['en']} #{grade_band['code']}"
      if !@curriculum_subjects_hash[subject_name]['matched']
        create_tracker_subject(subject, subject_name, grade_band)
        # puts "SUbject Created : #{subject_name}"
        
      else
        tracker_subject = Subject.where(school_id: 1, name: subject_name)
        if tracker_subject.empty?
          curriculum_subject = @curriculum_subjects_hash[subject_name]
          create_tracker_subject(subject, subject_name, grade_band)
          # puts "SUbject Created : #{subject_name}"
        end
      end
    end
  end
end

def create_tracker_subject(subject, subject_name, grade_band)
  disc = nil
  if @subjects_disciplines[subject_name]
    disc = create_or_find_discipline(@subjects_disciplines[subject_name])
  else
    disc = create_or_find_discipline('Others')
  end
  Subject.create(
    name: subject_name, 
    school_id: @model_school.id, 
    discipline_id: disc.id,
    active: true, 
    curr_tree_type_id: subject['tree_type_id'], 
    curr_subject_code: subject['code'], 
    curr_subject_id: subject['id'], 
    curr_grade_band_id: grade_band['id'], 
    curr_grade_band_code: grade_band['code'], 
    curr_grade_band_number: grade_band['min_grade']
  )
  @count += 1
  subject['matched'] = true
end


def subject_matched?(curriculum_subject, tracker_subject)
  subject_matched = false
  if curriculum_subject
    curriculum_subject['grade_bands'].each do |grade_band|
      get_curriculum_subject_name(curriculum_subject, grade_band)
      if @curriculum_subject_name == tracker_subject.name
        tracker_subject.update(
          active: curriculum_subject['active'], 
          curr_tree_type_id: curriculum_subject['tree_type_id'], 
          curr_subject_code: curriculum_subject['code'], 
          curr_subject_id: curriculum_subject['id'], 
          curr_grade_band_id: grade_band['id'], 
          curr_grade_band_code: grade_band['code'], 
          curr_grade_band_number: grade_band['min_grade']
        )
        subject_matched = true
      end
    end
  end
  subject_matched
end

def get_curriculum_subject_name(curriculum_subject, grade_band)
  curriculum_subject_name = "#{curriculum_subject['versioned_name']['en']}" 
  curriculum_grade_code = " #{grade_band['code']}"
  @curriculum_subject_name = curriculum_subject_name + curriculum_grade_code
end

def create_or_find_discipline(discipline)
  disc = nil
  match_ds = Discipline.where(name: discipline)
  if match_ds.empty?
    disc = Discipline.create(name: discipline)
  else
    disc = match_ds.first
  end
  disc
end
