
namespace :update_model_school do
  
  desc "Update model school subjects with subjects from curriculum."
  
  task update: :environment do
    include Sso::Constants
    user = user = User.where(system_administrator: true).last
    token = JWT.encode({email: user.email, code: 'egstem'}, secrets['json_api_key'])
    egstem_curr = Curriculum::Client.curriculums(token)['curriculums'].first
    puts "egstem curriculum :#{egstem_curr}".green
    model_school = School.first
    model_school.update(
      curr_tree_type_id: egstem_curr['id'], 
      curr_version_code: egstem_curr['version_code'],
      curriculum_code: egstem_curr['code']
    )

    curriculum_subjects = Curriculum::Client.subjects(token, model_school.curr_tree_type_id)['subjects']

    count = 0
    curriculum_subjects.each do |subject|
      subject['grade_bands'].each do |grade_band|
        if grade_band['min_grade'] == grade_band['max_grade']
          tracker_subject = Subject.where(school_id: model_school.id, name: "#{subject['versioned_name']['en']} #{grade_band['code']}")
          if tracker_subject.present?
            tracker_subject.update(
              active: true, 
              curr_tree_type_id: subject['tree_type_id'], 
              curr_subject_code: subject['code'], 
              curr_subject_id: subject['id'], 
              curr_grade_band_id: grade_band['id'], 
              curr_grade_band_code: grade_band['code'], 
              curr_grade_band_number: grade_band['min_grade']
            )
          end
        end
      end
    end
    puts "#{count} subjects have been updated"
    puts "Curriculum Subject: #{curriculum_subjects[6]}"
    puts "Updated Tracker Subject: #{Subject.where(school_id: 1, name: 'Math 1').first.attributes}".green
    # learning_outcomes = Curriculum::Client.learning_outcomes(token, subjects.first['tree_type_id'], subjects.first['id'])

  end

end