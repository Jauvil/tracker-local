namespace :sso_onboarding do

  desc 'Find a teacher from Tracker and create that teacher in curriculum'
  
  task create_demo_user: :environment do
    user = nil
    User.all.each do |poss_user|
      if poss_user.teacher?
        teacher = Teacher.find(poss_user.id)
        if teacher.sections.count > 1
          user = poss_user
          break
        end
      end
      break if user.present?
    end

    user.email = 'demo_teacher@21pstem.org'
    user.password = 'Simple123!'
    user.password_confirmation = 'Simple123!'
    user.save!
  end
end