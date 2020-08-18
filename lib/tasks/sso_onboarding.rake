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

  task create_system_admin_user: :environment do
    User.create!(username: 'adminuser', email: 'admin@21pstem.org',  password: 'Simple123!', password_confirmation: 'Simple123!', system_administrator: true)
  end

  task enroll_users: :environment do
    include Sso::SystemAdminRegistrations

    system_token = JWT.encode({email: 'system@21pstem.org', expires_at: Time.now + 1.hour}, Rails.application.secrets.json_api_key)
    total_users_count = User.count
    users_enrolled_count = 0
    users_without_emails = []
    User.all.each do |user|
      if user.email.blank?
        users_without_emails << user
        next
      end
      user.set_temporary_password
      user.save!
      perform_sso_signup(user, system_token)
      users_enrolled_count += 1
      UserMailer.enrolled_in_sso(user.id).deliver_now
    end

    data = {
        total_users_count: total_users_count,
        users_enrolled_count: users_enrolled_count,
        users_without_emails: users_without_emails
    }

    SystemMailer.onboarding_report(data).deliver_now
  end
end