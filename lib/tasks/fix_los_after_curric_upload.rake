# fix_los_after_curric_upload.rake


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


namespace :fix_los_after_curric_upload do
  desc "Fix sections when rollover was done before curriculum upload"

  task run: :environment do

    STDOUT.puts ("WARNING: DO NOT RUN THIS EXCEPT TO REPAIR THE DATABASE FOR MID-YEAR CURRICULUM UPLOAD.")
    STDOUT.puts ("enter 'I am sure' (without qoutes) to continue")
    answer = STDIN.gets.chomp.strip
    if answer == 'I am sure'
      STDOUT.puts 'Proceeding to fix curriculum in database'
    else
      raise "Aborting Run"
    end

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


    #################
    # loop through Model School subjects, and resequence the subject outcomes
    # To Do - put this into curriculum upload
    modelSubjIds.each do |modSubj|
      # STDOUT.puts("Subject: #{Subject.find(modSubj).name}")
      loCodes = {}
      modSubjos = SubjectOutcome.where(subject_id: modSubj, active: true).order(:lo_code)
      modSubjos.each do |modSubjo|
        # create hash with LO codes with all spaces removed
        loCodes[modSubjo.lo_code.gsub(/\s+/, "")] = modSubjo
      end
      # Sort hash by key
      sortedLoCodes = Hash[loCodes.sort_by {|key, value| key}]
      # output the los in the correct order
      sortedLoCodes.each_with_index do |(key, modSubjo), ix|
        # STDOUT.puts("  #{ix} #{key}  #{modSubjo.lo_code}")

        modSubjo.position = ix
        modSubjo.save
        modSubjo.reload
        # STDOUT.puts "    test: #{modSubjo.position} ==? #{ix}"
      end
    end

    #################
    # Next - loop through schools, fixing the matched Model School Subject Outcomes
    # - process the new Model School Subject Outcomes later


    # LOOP THROUGH SCHOOLS
    schoolsToFix.each do |sch|
      # get subjects to process for this School to process
      subjectsToProcessIds = Subject.where(school_id: sch).pluck(:id)
      # subjectsToProcessIds.count

      # get the School's subject outcomes from the subjects (of the school) to process
      subjosToProcess = SubjectOutcome.where(subject_id: subjectsToProcessIds)
      # subjosToProcess.count

      # Get the School's current sections for this year
      # note: we do not want to touch prior year's class/sections
      currentSections = Section.where(subject_id: subjectsToProcessIds, school_year_id: sch.school_year_id)
      currentSectionIds = currentSections.pluck(:id)
      # currentSections.count

      # loop through School Subject Outcomes to process
      subjosToProcess.each do |subjo|
        model_lo = SubjectOutcome.find(subjo.model_lo_id)
        lo_sectos = SectionOutcome.where(subject_outcome_id: subjo.id, section_id: currentSectionIds)
        if model_lo.active
          puts "#{subjo.id} - update - #{subjo.lo_code} to #{model_lo.lo_code}"
          subjo.lo_code = model_lo.lo_code
          subjo.description = model_lo.description
          subjo.marking_period = model_lo.marking_period
          subjo.position = model_lo.position
          # subjo.model_lo_id = model_lo.id # should not change
          lo_sectos.each do |secto|
            secto.position = model_lo.position
            secto.save
          end
      else
          lo_esos = EvidenceSectionOutcome.where(section_outcome_id: lo_sectos)
          if lo_esos.count != 0
            puts "#{subjo.id} - deactivate - #{subjo.lo_code} to X-#{model_lo.lo_code}-X"
            subjo.lo_code = "X-"+subjo.lo_code+"-X"
            subjo.description = "X-"+subjo.description+"-X"
            lo_sectos.each do |secto|
              secto.position = nil
              secto.save
            end
          else
            puts "#{subjo.id} - deactivate - #{subjo.lo_code} to #{model_lo.lo_code}"
            lo_sectos.each do |secto|
              secto.active = false
              subjo.position = nil
              secto.save
            end
          end

          # always deactivate the unmatched School Subject Outcome, so it will not be used again
          subjo.active = false
        end # model_lo_active
        subjo.save
        subjo.reload
        puts "#{subjo.id} - #{subjo.lo_code} - #{subjo.active} - #{subjo.description} "
      end

      # # also check counts of processed Model School Subject Outcomes
      # # Process to create new subject outcomes for school
      # usedSubjoIdsFromModel = SubjectOutcome.where(subject_id: subjectsToProcessIds).pluck(:model_lo_id).uniq
      # unusedModelSubjoIds = modelSchSubjoIds - usedSubjoIdsFromModel

      # unusedModelSubjos = SubjectOutcome.where(id: unusedModelSubjoIds)

      # # check the Model School used counts
      # if ((usedSubjoIdsFromModel + unusedModelSubjos).count != modelSchSubjoIds.count)
      #   raise ("check model school used counts: #{(usedSubjoIdsFromModel + unusedModelSubjos)} 1= #{modelSchSubjoIds.count}")
      # end

      # # loop through unused model section outcomes
      # # to create the subject outcome for this school
      # unusedModelSubjos.each do |subjo|
      #   # get the school's subject_id (matching the name of the Model school's subject)
      #   modSubj = Subject.where(id: subjo.subject_id).first
      #   schSubjs = Subject.where(name: modSubj.name, school_id: sch.id)
      #   if schSubjs.count == 0
      #     # new subject, create it
      #     puts "Create school subject for : #{modSubj.name}"
      #     schSubj = Subject.new
      #     schSubj.name = modSubj.name
      #     schSubj.discipline_id = modSubj.discipline_id
      #     schSubj.school_id = sch.id
      #     # schSubj.save
      #   elsif schSubjs.count == 1
      #     schSubj = schSubjs.first
      #   else
      #     raise("ERROR - duplicate subjects for school name: #{modSubj.name}, school: #{sch.id}")
      #   end

      #   schSubjos = SubjectOutcome.where(subject_id: schSubj.id)

      #   # create new school subject outcome from model school subject outcome4
      #   puts "Create subjo: #{subjo.lo_code}"
      #   subjoSch = SubjectOutcome.new
      #   subjoSch.lo_code = subjo.lo_code
      #   subjoSch.description = subjo.description
      #   subjoSch.marking_period = subjo.marking_period
      #   subjoSch.subject_id = schSubj.id
      #   subjoSch.model_lo_id = subjo.id
      #   # subjoSch.save

      #   # for each course/section of the subject, create the section outcome
      #   currentSections.each do |sect|
      #     # next create section outcome for course/section
      #     if sect.id != sect.subject_id
      #       throw "ERROR - Create secto - section: #{sect.id} != #{sect.subject_id}"
      #     end
      #     secto = SectionOutcome.new
      #     secto.section_id = sect.id
      #     secto.subject_outcome_id = subjoSch.id
      #     secto.marking_period = subjoSch.marking_period
      #     # secto.save
      #   end
      # end # unusedModelSubjos each

    end # schoolsToFix.each

    #################
    # Next - loop through schools, fixing the matched Model School Subject Outcomes
    # - process the new Model School Subject Outcomes later
    raise ("to create new subject outcomes and section outcomes in schools / subjects / sections")

    # cur_subj_id = model_los.first.id
    # puts "#{model_los.first.subject.name}, cur_subj_id: #{cur_subj_id}"
    # model_los.each do |mlo|
    #   if cur_subj_id != mlo.subject_id
    #     puts "#{mlo.subject.name}, cur_subj_id: #{cur_subj_id}"
    #   end
    #   cur_subj_id = mlo.subject_id
    #   rel_lo = mlo.model_lo_id.nil? ? [] : SubjectOutcome.where(id: mlo.model_lo_id)
    #   if rel_lo.count == 1
    #     # model_lo_id has value, display the Model School Learning Outcome record pointed to
    #     puts("    LO.id:code: #{mlo.id}:#{mlo.lo_code}, LO.active: #{mlo.active}, LO.model_lo_id: #{mlo.model_lo_id}, #{rel_lo.lo_code}, #{rel_lo.active}")
    #   else
    #     # no model_lo_id value, nothing to see here.
    #     puts("    LO.id:code: #{mlo.id}:#{mlo.lo_code}, LO.active: #{mlo.active}")
    #   end
    # end

  end # task run:
end # namespace :fix_rollover_before_curriculum


