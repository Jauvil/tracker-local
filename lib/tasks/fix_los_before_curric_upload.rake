# fix_rollover_before_curriculum.rake


# one time fix to safely remove the In-Class evidence type.
# all evidences using In-Class evidence type will be replace with the In Class evidence type.
# then the In-Class evidence type will be removed

####################################################################
# Development Setup:

####################################################################
# Development Setup - Preparation:
# 1) to clear subjects and Los from model school:
#   bundle exec rake curriculum_school:clear_model_school
# 2) load up the curriculum subjects into the model school
#   bundle exec rake stem_egypt_model_subjects:populate
#   - should set school year to 2018-2019
# 3) load in the initial curriculum (subject outcomes into model school)
#   bundle exec rails server
#
#   https:localhost:3000/schools / Model School / Upload Learning Outcomes
#   upload the InitialEgCurriculumMinCols.csv file for all subjects
#   - Should return:
#     Automatically Updated Subjects counts: Updates - 0 , Adds - 647 , Deactivates - 0 , Errors - 0
#     Grand total counts: Subjects Updated - 64 , Updates - 0 , Adds - 647 , Deactivates - 0 , Errors - 0

#   - Model school listing should have LOS under Subjects Outcomes


####################################################################
# Development Setup - First Year Setup:
# To load up first year (steps may be repeated):
# 1) if need to clear (delete) CUS school (for rerunning)
#  bundle exec rake curriculum_school:clear_cus
# 2) (re)create the school and school years record
#   https:localhost:3000/schools / + (Create) / Acronym CUS
#   - CUS school listing should have all model school subjects with LOS under Subjects Outcomes
# 3) Load in activity for year 1
#      bundle exec rake curriculum_school:load

# 4) simulate school year rollover with no learning outcome changes
# load in the initial curriculum (subject outcomes into model school)
#   https:localhost:3000/schools / Model School / Upload Learning Outcomes
#   upload the InitialEgCurriculumMinCols.csv file for all subjects
#   - Should return:
#     Automatically Updated Subjects counts: Updates - 0 , Adds - 0 , Deactivates - 0 , Errors - 0
#     Grand total counts: Subjects Updated - 0 , Updates - 0 , Adds - 0 , Deactivates - 0 , Errors - 0


####################################################################
# Development Setup - Rollover without curriculum update:
# 1) Roll over the school years after doing appropriate updates to curriculum learning outcomes.
#     https:localhost:3000/schools / model school / rollover to new year
#     https:localhost:3000/schools / Curriculum Update School / rollover to new year

# 2) Confirm that all sections are in the previous year
#     https:localhost:3000/schools / Curriculum Update School / <click the building icon - Make CUS current school>
#  Click on the Staff Toolkit item. Will return the All Sections for all Staff Members
#  Click on Check Mark for one of the teachers.  Will return the All Sections for the Staff Member
#  - there should be no sections under Current Sections
#  - last year sections should be listed under Previous Sections

# 3) load up activity for the new year
#      bundle exec rake curriculum_school:load

# 4) Optionally - Confirm that all sections are in the current year
#  Click on the Staff Toolkit item. Will return the All Sections for all Staff Members
#  Click on Check Mark for one of the teachers.  Will return the All Sections for the Staff Member
#  - there should be sections under both Current Sections and Previous Sections


####################################################################
# Development Setup - Mid semester/year curriculum change
# load in the updated curriculum (subject outcomes into model school)
#   https:localhost:3000/schools / Model School / Upload Learning Outcomes
#   upload the Egypt STEM Schools Curriculum - Reviewed Coursesv3.csv file for all subjects
#   - Use the Mapping spreadsheet to map unmatched new learning outcomes to the old ones.
#     Note: filter the Old LO Option Code to only show fields with * (fields requiring input to Tracker):
#     EgyptSTEMSchoolsCurriculumMatchedOldLOs.xlsx
#   - After all matching is done, the following should(?) be shown:
# ???


####################################################################
# Run Fix of Old Learning Outcomes in Class Section for current year
# bundle exec rake fix_rollover_before_curriculum:run


namespace :fix_los_before_curric_upload do
  desc "Fix sections when rollover was done before curriculum upload"

  task run: :environment do

    schoolsToFix = []

    STDOUT.puts "Please confirm the following schools should be fixed:"

    # Get Model School
    modelSchool = School.find(1)
    if !modelSchool
      raise("Missing Model School")
    end

    # get Model School Subjects
    modelSubjIds = Subject.where(school_id: modelSchool.id).pluck(:id)
    raise ("Mising Model School subjects - count: #{modelSubjIds.count}") if modelSubjIds.count < 1

    # get Model School Subject Outcome ids
    modelSchSubjoIds = SubjectOutcome.where(subject_id: modelSubjIds).pluck(:id)
    modelSchSubjoIds.count

    # get the subject ids of outcomes referencing a model school outcome
    # get School Subject Outcomes where they reference a model school subject outcome, and return the unique subject ids
    subjoIdsFromModel = SubjectOutcome.where(model_lo_id: modelSchSubjoIds).pluck(:subject_id).uniq
    raise ("Reference Model School Subject Outcomes - count: #{subjoIdsFromModel.count}") if subjoIdsFromModel.count < 1

    # get the Schools that have School Subject Outcomes that reference Model School Subject Outcome ids
    schRefModelLos = Subject.where(id: subjoIdsFromModel).pluck(:school_id).uniq

    # Fix schools from the Schools that have School Subject Outcomes, but skip Model school and training schools
    School.where(id: schRefModelLos).each do |sch|
      if sch.acronym[0..1] == 'LT'
        # leadership training school, do not process
      elsif sch.id < 3
        # model school or training school, do not process
      else
        schoolsToFix << sch
        STDOUT.puts "  Fix school: #{sch.acronym} - #{sch.name}"
      end
    end

    STDOUT.puts ("hit enter to continue and process all the above schools !!!")
    answer = STDIN.gets.chomp.strip
    if answer != ''
      raise("Aborting Run")
    end


    # all subjects for all schools to process
    allSubjectsToProcessIds = Subject.where(school_id: schoolsToFix.pluck(:id)).pluck(:id)

    # all subject outcomes for all schools to process
    allSubjosToProcess = SubjectOutcome.where(subject_id: allSubjectsToProcessIds)

    test = SubjectOutcome.where(id: allSubjosToProcess.pluck(:id), model_lo_id: nil)
    if test.count > 0
      raise("System Error: Must fix Subject Outcomes Model School LO pointers before Curriculum Upload and LO fix")
    else
      STDOUT.puts("All is good!")
    end

  end # task run:
end # namespace :fix_rollover_before_curriculum


