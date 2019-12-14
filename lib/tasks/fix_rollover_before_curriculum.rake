# fix_rollover_before_curriculum.rake

namespace :fix_rollover_before_curriculum do
  desc "Fix sections when rollover was done before curriculum upload"

  task run: :environment do

    schools_to_fix = []

    puts ("WARNING: DO NOT RUN THIS EXCEPT TO REPAIR THE DATABASE FOR MID-YEAR CURRICULUM UPLOAD.")
    puts ("enter 'I am sure' or 'I am testing' (without qoutes) to continud")
    answer = STDIN.gets.chomp.strip
    if answer == 'I am sure'
      STDOUT.puts 'Proceeding to fix curriculum in database'
      School.all.each do |sch|
        if sch.acronym[0..1] == 'LT'
          # leadership training school, do not process
        elsif sch.id < 3
          # model school or training school, do not process
        else
          schools_to_fix << sch
        end
      end
    elsif answer == 'I am testing'
      STDOUT.puts 'Proceeding to test curriculum fix'
      schools_to_fix = School.where(acronym: 'CUS')
    else
      raise "Aborting Run"
    end

    puts "schools to fix: #{schools_to_fix.pluck(:name)}"
    puts ("hit enter to continud")
    answer = STDIN.gets.chomp.strip
    if answer != ''
      raise("Aborting Run")
    end


    model_school = School.find(1)
    if !model_school
      raise("Missing Model School")
    end

    model_subject_ids = Subject.where(school_id: model_school.id).pluck(:id)

    # puts ("model_subject_ids: #{model_subject_ids.inspect}")

    model_los = SubjectOutcome.where(subject_id: model_subject_ids)

    cur_subj_id = model_los.first.id
    puts "#{model_los.first.subject.name}, cur_subj_id: #{cur_subj_id}"
    model_los.each do |mlo|
      if cur_subj_id != mlo.subject_id
        puts "#{mlo.subject.name}, cur_subj_id: #{cur_subj_id}"
      end
      cur_subj_id = mlo.subject_id
      rel_lo = mlo.model_lo_id.nil? ? [] : SubjectOutcome.where(id: mlo.model_lo_id)
      if rel_lo.count == 1
        puts("    #{mlo.id}:#{mlo.lo_code}, #{mlo.active}, #{mlo.model_lo_id}, #{rel_lo.lo_code}, #{rel_lo.active}")
      else
        puts("    #{mlo.id}:#{mlo.lo_code}, #{mlo.active}")
      end
    end


  end # run
end # namespace


