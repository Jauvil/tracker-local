# curriculum_school.rake


# Preparatory Procedures:
# 1) to clear subjects and Los from model school:
#   bundle exec rake curriculum_school:clear_model_school
# 2) load up the curriculum subjects into the model school
#   bundle exec rake stem_egypt_model_subjects:populate
#   - should set school year to 2018-2019
# 3) load in the initial curriculum (subject outcomes into model school)
#   https:localhost:3000/schools / Model School / Upload Learning Outcomes
#   upload the InitialEgCurriculumMinCols.csv file for all subjects
#   - Should return:
#     Automatically Updated Subjects counts: Updates - 0 , Adds - 647 , Deactivates - 0 , Errors - 0
#     Grand total counts: Subjects Updated - 64 , Updates - 0 , Adds - 647 , Deactivates - 0 , Errors - 0

#   - Model school listing should have LOS under Subjects Outcomes


# To load up first year (steps may be repeated):
# 1) if need to clear (delete) CUS school (for rerunning)
#  bundle exec rake curriculum_school:clear
# 2) (re)create the school and school years record
#   https:localhost:3000/schools / + (Create) / Acronym CUS
#   - CUS school listing should have all model school subjects with LOS under Subjects Outcomes
# 3) Load in activity for year 1
#      bundle exec rake curriculum_school:load

# 4)
# To simulate school year rollover without updating learning outcomes
# load in the initial curriculum (subject outcomes into model school)
#   https:localhost:3000/schools / Model School / Upload Learning Outcomes
#   upload the InitialEgCurriculumMinCols.csv file for all subjects
#   - Should return:
#     Automatically Updated Subjects counts: Updates - 0 , Adds - 0 , Deactivates - 0 , Errors - 0
#     Grand total counts: Subjects Updated - 0 , Updates - 0 , Adds - 0 , Deactivates - 0 , Errors - 0

#
# For a standard school year rollover without updating learning outcomes
# load in the initial curriculum (subject outcomes into model school)
#   https:localhost:3000/schools / Model School / Upload Learning Outcomes
#   upload the EgyptSTEMSchoolsCurriculum-19-20-mincols.csv file for all subjects
#   - Should return:

# 5) Roll over the school years after doing appropriate updates to curriculum learning outcomes.
#     https:localhost:3000/schools / model school / rollover to new year
#     https:localhost:3000/schools / Curriculum Update School / rollover to new year

# 6) Confirm that all sections are in the previous year
#  Click on Check Mark for one of the teachers.  Will return the All Sections for Staff Members
#  - there should be no sections under Current Sections, and last year sections under Previous Sections

# 7) load up activity for the new year
#      bundle exec rake curriculum_school:load




###########################################################
# create 4 evidences / ESOs per section outcome per student enrolled

# For evidence Types R and BA, with no Blue rating (2/3 green, 1/3 others)
e_ratings = ["R","Y","U","M","G","G","G","G","G","G","G","G"]

# Strategic Evidence Type (ST) with Blue rating (1/3 green, 1/3 blue, 1/3 others)
eh_ratings = ["R","Y","U","M","B","B","B","B","G","G","G","G"]

# load 4 subject outcomes as section outcomes (2 sem 1, 2 sem 2)
# los_a = [
#   ['LO.1.01', 'Curriculum Learning Outcome 1', '1'],
#   ['LO.1.02', 'Curriculum Learning Outcome 2', '1'],
#   ['LO.1.03', 'Curriculum Learning Outcome 3', '2'],
#   ['LO.1.04', 'Curriculum Learning Outcome 4', '2']
# ]

# Create Sections
NUM_SECTIONS = 3
MODEL_SCHOOL_ID = 1
sections = []

# create Students (6 set names)
students = []
students_a = [
  ['M', 'Ali', 'Amgad Kamal', 'ETH_aamgad.kamal', 'aamgad.kamal@sample.com'],
  ['F', 'Doaa', 'Salan Elsayed', 'ETH_dsalan.elsayed', 'dsalan.elsayed@sample.com'],
  ['M', 'Fady', 'Adel Fahmy', 'ETH_fadel.fahmy', 'fadel.fahmy@sample.com'],
  ['F', 'Israa', 'Mostafa Badran', 'ETH_imostafa.badran', 'imostafa.badran@sample.com'],
  ['M', 'Hager', 'Naser Mahmoud', 'ETH_hnaser.mahmoud', 'hnaser.mahmoud@sample.com'],
  ['F', 'Mara', 'Saeid Mousa', 'ETH_msaeid.mousa', 'msaeid.mousa@sample.com']
]

# create our evidence types
ets=["In Class", "Homework", "Quiz", "Test"]

# evidence types: Recall, Basic Applcation & Strategic Thinking
et_levels = ['R', 'BA', 'ST', 'ST']


namespace :curriculum_school do
  desc "Create Curriculum Update School."

  task load: :environment do

    schools = School.where(acronym: 'CUS').all
    if schools.count < 1
      # school = School.create!(
      #   name: "Curriculum Update School",
      #   acronym: 'CUS',
      #   street_address: "1 Stub Lane",
      #   city: "Conshohocken",
      #   state: "PA",
      #   zip_code: "19428",
      #   marking_periods: 2
      # )
      raise("Curriculum School does not already exist.  Create it using website, after model school subject load and curriculum upload")
    else
      school = schools.first
    end


    sy1s = SchoolYear.where(school_id: school.id, name: "2018, 2019")
    sy2s = SchoolYear.where(school_id: school.id, name: "2019, 2020")
    if sy1s.count < 1
      school_year1 = SchoolYear.create!(
        name: "2018, 2019",
        school_id: school.id,
        starts_at: Date.parse("2018-09-01"),
        ends_at: Date.parse("2019-06-20")
      )
    end
    if sy2s.count < 1
      school_year2= SchoolYear.create!(
        name: "2019, 2020",
        school_id: school.id,
        starts_at: Date.parse("2019-09-01"),
        ends_at: Date.parse("2020-06-20")
      )
    end

    # if creating school, set the school year to the first year
    if school.school_year_id == nil
      school.school_year_id = school_year1.id
      school.save!
    end

    subjects = Subject.where(school_id: school.id)
    if subjects.count == 0
      raise "ERROR: Need to create model school subjects. run: bundle exec rake stem_egypt_model_subjects:populate, before manually creating school."
    end

    evidence_types = []
    ets.each do |et|
      db_et = EvidenceType.where(name: et)
      if db_et.count > 0
        evidence_types << db_et.first
      else
        e = EvidenceType.create(name: et)
        evidence_types << e
      end
    end

    # create 6 students (see students_a)
    students_a.each do |stu_info|
      users = User.where("username like '#{stu_info[3]}'")
      if users.count == 0
        # create new student
        stu = Student.new()
        stu.username =  stu_info[3]
        stu.first_name = stu_info[1]
        stu.last_name = stu_info[2]
        stu.email = stu_info[4]
        stu.grade_level = 1
        stu.gender = stu_info[0]
        stu.school_id = school.id
        stu.password = "password"
        stu.password_confirmation = "password"
        if !stu.save
          STDOUT.puts("*** stu.username: #{stu.username.inspect} #{stu_info[3].inspect}")
          raise "!!!!! ERROR: create assessment student error #{stu.errors.full_messages}!!!!!"
          # next
        end
      elsif users.count == 1
        stu = users.first
      else
        raise "ERROR: duplicate assessment student #{stu_info[3]}"
      end
      students << stu
    end

    evid_seq = 1

    subjects.each do |subj|

      mod_sch_subj = Subject.where(school_id: MODEL_SCHOOL_ID, name: subj.name).first

      raise("missing model school subject for #{subj.name}") if !mod_sch_subj

      subjouts = SubjectOutcome.where(subject_id: subj.id)

      # create one teacher per subject
      matchTeacher = User.where("username like '#{subj.name}Teacher'")
      if matchTeacher.count == 0
        t = Teacher.new()
        t.username = "#{subj.name}Teacher"
        t.first_name = subj.name
        t.last_name = "Teacher"
        t.school_id = school.id
        t.password = "password"
        t.password_confirmation = "password"
        if !t.save
          raise "!!!!! ERROR: create teacher '#{subj.name}Teacher' error #{t.errors.full_messages}!!!!!"
          # next
        end
      elsif matchTeacher.count == 1
        t = matchTeacher.first
      else
        raise "ERROR: duplicate teacher #{subj.name}Teacher"
      end

      # create sections then add subject outcomes, students and teacher to ie
      (1..NUM_SECTIONS).each do |n|

        # create the section
        s = Section.new()
        s.line_number = "#{subj.name} Section #{sprintf('%03d',n)}"
        s.subject_id = subj.id
        s.school_year_id = school.school_year_id
        s.message = ["Homework Due Thursday!!", "Quiz on Friday !!!!"][n % 2]
        if !s.save
          raise "!!!!! ERROR: create section error #{s.errors.full_messages}, errors: #{s.errors.inspect}!!!!!"
          # next
        end
        sections << s

        # assign the teacher to the section
        ta = TeachingAssignment.new()
        ta.teacher_id = t.id
        ta.section_id = s.id
        if !ta.save
          raise "!!!!! ERROR: create assessment teaching assignment error #{ta.errors.full_messages}: #{e.errors.inspect}!!!!!"
          # next
        end

        # Enroll students into each section
        students.each_with_index do |stud, ix|
          # put two students into each of the three sections
          if (ix / 2 == n-1)
            e = Enrollment.new()
            e.student_id = stud.id
            e.section_id = s.id
            e.student_grade_level = stud.grade_level
            if !e.save
              raise "!!!!! ERROR: create assessment enrollment error #{e.errors.full_messages}: #{e.errors.inspect}!!!!!"
              # next
            end
          end
        end # students.each
        # Create Section Outcomes for this section (LOs copied to each section)
        posit = 1
        subjouts.each do |so|
          # create the section (with a position number - only first LO has SORs, first 2 have ESORs)
          has_secto = SectionOutcome.where(section_id: s.id, subject_outcome_id: so.id)
          if has_secto.count == 0
            secto = SectionOutcome.new
            secto.section_id = s.id
            secto.subject_outcome_id = so.id
            secto.marking_period = so.marking_period
            secto.position = posit
            posit += 1
            raise("ERROR: error saving Section Outcome #{s.line_number} - #{so.lo_code} - error: #{secto.errors.full_messages}") if !secto.save
          else
            raise 'ERROR: Sections already exist for Subject'
          end

          # add evidence and evidence_section_outcome to first two Section Outcomes
          # puts "secto.position: #{secto.position}: #{secto.inspect}"
          if secto.position < 3

            # create evidences for this section (for this section outcome)
            evidence_types.each_with_index do |et, ix|
              # puts "*** et: #{et.name}"
              e = Evidence.create(
                section_id: s.id,
                name: "Sample Evidence #{evid_seq} (#{et_levels[ix]})",
                description: "Basically, evidences are homework assignments, tests, quizzes, etc.",
                assignment_date: DateTime.now,
                active: true,
                evidence_type_id: et.id,
                reassessment: false
              )
              eso = EvidenceSectionOutcome.create(
                evidence_id: e.id,
                section_outcome_id: secto.id
              )
              # evidence_section_outcomes << eso
              evid_seq += 1

              # create ratings
              # only have blue ratings for evidence types with strategic thinking
              cur_ratings = (ix > 2) ? eh_ratings : e_ratings

              # create evidence section outcome rating (esor)
              students.each do |student|
                rating = cur_ratings[Random.rand(12)]
                esor = EvidenceSectionOutcomeRating.create(
                  rating: rating,
                  student_id: student.id,
                  evidence_section_outcome_id: eso.id,
                  comment: ""
                )

                # section outcome rating (sor) based upon evidence rating
                sorating = "H" if ["B"].include?(rating)
                sorating = "P" if ["G"].include?(rating)
                sorating = "N" if ["Y","R"].include?(rating)
                sorating = "U" if ["U","M"].include?(rating)

                # only create section outcome ratings for first section outcome
                if secto.position < 2
                  SectionOutcomeRating.create(
                    rating: sorating,
                    student_id: student.id,
                    section_outcome_id: secto.id
                  )
                end
              end # students

            end # evidence types

          end # secto.position < 3

        end # subjouts.each

      end # sections.each

    end # subjects.each
    STDOUT.puts "curriculum_school:setup DONE!"

  end # end create_training_ratings


  task clear: :environment do

    # !!!!!\nWARNING: CAUTION MODIFYING THIS CODE - MISTAKE COULD DELETE LIVE DATA. !!!!!!!!

    schools = School.where(acronym: 'CUS').all
    if schools.count > 0

      school = schools.first

      puts 'Starting clear curriculum_school'

      User.delete_all(school_id: school.id)
      puts "all users have been deleted"
      (Section.where(school_year_id: school.school_year_id)).each do |sect|
        (SectionOutcome.where section_id: sect.id).each do |so|
          (EvidenceSectionOutcome.where section_outcome_id: so.id).each do |eso|
            EvidenceSectionOutcomeRating.delete_all(evidence_section_outcome_id: eso.id)
            eso.delete
          end
          SectionOutcomeRating.delete_all(section_outcome_id: so.id)
          so.delete
        end
        Evidence.delete_all(section_id: sect.id )
        Enrollment.delete_all(section_id: sect.id )
        TeachingAssignment.delete_all(section_id: sect.id )
        sect.delete
        puts "Section #{sect.name} - #{sect.line_number} has been deleted"
      end

      (Subject.where(school_id: school.id)).each do |subj|
        SubjectOutcome.delete_all(subject_id: subj.id)
        Subject.delete_all(school_id: school.id)
      end

      SchoolYear.delete_all(school_id: school.id)
      School.delete_all(id: school.id)


      puts "Done"

    end

  end # clear curriculum_school

  task clear_model_school: :environment do

    # !!!!!\nWARNING: CAUTION MODIFYING THIS CODE - MISTAKE COULD DELETE LIVE DATA. !!!!!!!!

    schools = School.where(id: 1).all
    if schools.count > 0

      school = schools.first

      puts 'Starting clear model school subjects and subject outcomes'

      (Subject.where(school_id: 1)).each do |subj|
        SubjectOutcome.delete_all(subject_id: subj.id)
        Subject.delete_all(school_id: school.id)
      end

      sy = SchoolYear.where(school_id: 1, name: '2018-2019')
      if sy.count > 0
        # set model school year to 18-19
        school.school_year_id = sy.first.id
        school.save
      else
        puts "cannot find 1819 school year for model school"
      end

      puts "Done"

    end

  end # clear curriculum_school

end
