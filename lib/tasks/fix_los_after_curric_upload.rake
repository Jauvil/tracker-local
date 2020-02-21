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
# bundle exec rake fix_los_after_curric_upload:run


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


    # Loop Through Schools To Fix
    schoolsToFix.each do |sch|
      # get subjects to process for this School to process
      subjectsToProcessIds = Subject.where(school_id: sch).pluck(:id)

      # get the School's subject outcomes from the subjects (of the school) to process
      subjosToProcess = SubjectOutcome.where(subject_id: subjectsToProcessIds)

      # Get the School's current sections for this year
      # note: we do not want to touch prior year's class/sections
      currentSections = Section.where(subject_id: subjectsToProcessIds, school_year_id: sch.school_year_id)
      currentSectionIds = currentSections.pluck(:id)

      #################
      # First, fix the existing Subject and Section outcomes that have changed.

      # loop through all of the School's Subject Outcomes
      subjosToProcess.each do |subjo|
        model_lo = SubjectOutcome.find(subjo.model_lo_id)
        lo_sectos = SectionOutcome.where(subject_outcome_id: subjo.id, section_id: currentSectionIds)
        # Fix the School Subject Outcomes (that existed already / matched Model School Subject Outcomes)
        # if the this LO is still active in the curriculum (in the model subject outcome record), update the code and description.  This will be automatically reflected in tracker, as the section outcome references the lo_code and description from the school subject outcome record.
        if model_lo.active
          subjo.lo_code = model_lo.lo_code
          subjo.description = model_lo.description
          subjo.marking_period = model_lo.marking_period
          subjo.position = nil
          puts "subjo: #{subjo.id} - position #{subjo.position} - update - #{subjo.lo_code} to #{model_lo.lo_code}"
          # save at end
        else
          # Fix the Section Outcomes for this subject outcome
          # This LO has been deactivated in the curriculum (in the model subject outcome record).  We will need to deactivate the records in tracker.
          #  Note: if there are any evidences on the section outcome, we do not want to deactivate the section outcome, just simply mark the lo-code and description as desactivated with a leading 'X-', and trailing '-X'.
          # If there are no evidences, we can simply deactivate the section outcome and let it disappear from the tracker page.
        currentSections.each do |sect|
            lo_sectos = SectionOutcome.where(subject_outcome_id: subjo.id, section_id: sect.id)
            lo_esos = EvidenceSectionOutcome.where(section_outcome_id: lo_sectos)
            if lo_esos.count != 0
              # section LO has evidences, the section outcome must not be deactivated and must be shown in tracker as deactivated
              puts "subjo: #{subjo.id} - position #{subjo.position}  - x--x deactivate - #{subjo.lo_code} to X-#{model_lo.lo_code}-X"
              subjo.lo_code = "X-"+subjo.lo_code+"-X"
              subjo.description = "X-"+subjo.description+"-X"
            else
              # We have no evidences for this Section LO, so it can be deactivated
              puts "#{subjo.id} - deactivate - #{subjo.lo_code} to #{model_lo.lo_code}"
              # Deactivate the section outcome (should only be one section outcome)
              lo_sectos.each do |secto|
                secto.active = false
                secto.save!
                if secto.errors.count > 0
                  STDOUT.puts "save secto error: #{secto.errors.inspect}"
                else
                  STDOUT.puts "  saved secto id: #{secto.id} position: #{secto.position} subject_outcome_id: #{secto.subject_outcome_id}"
                end
              end
              puts "subjo: #{subjo.id} - position #{subjo.position}  - regular deactivate - #{subjo.lo_code}"
            end
          end
          # always deactivate the unmatched School Subject Outcome, so it will not be used again
          subjo.active = false
        end # model_lo_active
        subjo.save!
        subjo.reload
        puts "saved subjo: #{subjo.id} - #{subjo.lo_code} - #{subjo.position} - #{subjo.active} - #{subjo.description} "
      end

      # # also check counts of processed Model School Subject Outcomes
      # # Process to create new subject outcomes for school
      usedSubjoIdsFromModel = SubjectOutcome.where(subject_id: subjectsToProcessIds).pluck(:model_lo_id).uniq
      unusedModelSubjoIds = modelSchSubjoIds - usedSubjoIdsFromModel

      unusedModelSubjos = SubjectOutcome.where(id: unusedModelSubjoIds)

      #################
      # Next, fix the Section Outcomes  Subject Outcomes)

      # loop through unused model section outcomes
      # to create the subject outcome for this school
      unusedModelSubjos.each do |subjo|
        # get the school's subject_id (matching the name of the Model school's subject)
        modSubj = Subject.where(id: subjo.subject_id).first
        schSubjs = Subject.where(name: modSubj.name, school_id: sch.id)
        if schSubjs.count == 0
          # new subject, create it
          raise "SYSTEM ERROR: missing school subject for : #{modSubj.name}"
          schSubj = Subject.new
          schSubj.name = modSubj.name
          schSubj.discipline_id = modSubj.discipline_id
          schSubj.school_id = sch.id
          # schSubj.save
        elsif schSubjs.count == 1
          schSubj = schSubjs.first
        else
          raise("ERROR - duplicate subjects for school name: #{modSubj.name}, school: #{sch.id}")
        end

        puts("Create #{schSubj.id}'s subject for subjo: #{subjo.id} is: #{subjo.subject_id}")

        # create new school subject outcome from model school subject outcome4
        subjoSch = SubjectOutcome.new
        subjoSch.lo_code = subjo.lo_code
        subjoSch.description = subjo.description
        subjoSch.marking_period = subjo.marking_period
        subjoSch.subject_id = schSubj.id
        subjoSch.model_lo_id = subjo.id
        puts "Create subjo: #{subjo.lo_code} for model subjo: #{subjo.id}"
        subjoSch.save
        puts "Created subjo: #{subjoSch.lo_code} for model subjo: #{subjo.id} has id: #{subjoSch.id}"

        # for each course/section of the subject, create the section outcome
        Section.where(subject_id: schSubj, school_year_id: sch.school_year_id).each do |sect|
          # next create section outcome for course/section
          STDOUT.puts ("Section #{sect.id} subject_id: #{sect.subject_id}")
          STDOUT.puts ("School Subject Outcome #{subjoSch.id} has subject_id: #{subjoSch.subject_id}")
          if subjoSch.subject_id != sect.subject_id
            throw "ERROR - Create secto - section: #{subjoSch.subject_id} != #{sect.subject_id}"
          end
          schSecto = SectionOutcome.new
          schSecto.section_id = sect.id
          schSecto.subject_outcome_id = subjoSch.id
          schSecto.marking_period = subjoSch.marking_period
          puts "Create schSecto for section: #{sect.id} for school subjo: #{subjoSch.id}"
          schSecto.save
          puts "Created schSecto for section: #{schSecto.section_id} for school subjo: #{schSecto.subject_outcome_id} with id: #{schSecto.id}"
        end
      end # unusedModelSubjos each

    # First, fix the matched Model School Subject Outcomes
      # Fix section outcome positions so tracker page lists outcomes in lo_code order
      # Get all sections for this school
      currentSections.each do |sect|
        # get all section outcomes for this section
        sectos = SectionOutcome.where(section_id: sect, active: true)
        # get subject outcomes for this section
        subjoIds = sectos.pluck(:subject_outcome_id).uniq
        subjos = SubjectOutcome.where(id: subjoIds)
        # create hash with LO codes with all spaces removed
        loCodes = {}
        subjos.each do |subjo|
          loCodes[subjo.lo_code.gsub(/\s+/, "")] = subjo
        end
        # Sort hash by key
        sortedLoCodes = Hash[loCodes.sort_by {|key, value| key}]
        # create hash of lo_code by subject_outcome_id
        loCodeBySubjoId = {}
        sortedLoCodes.each_with_index do |(key, subjo), ix|
          loCodeBySubjoId[subjo.id] = ix+1
        end
        SectionOutcome.where(section_id: sect).each do |secto|
          posit = loCodeBySubjoId[secto.subject_outcome_id]
          upd = SectionOutcome.update(secto.id, position: posit)
          STDOUT.puts "Position update error: #{upd.errors.inspect}" if upd.errors.count > 0
        end
      end

    end # schoolsToFix.each

  end # task run:
end # namespace :fix_rollover_before_curriculum


