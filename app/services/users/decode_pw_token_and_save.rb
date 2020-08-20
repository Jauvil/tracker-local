class Users::DecodePwTokenAndSave
  def self.perform(user_params)
    obj = new(user_params)
    obj.run
  end

  def initialize(user_params)
    @params = user_params
  end

  def run
    password_token = @params.delete(:password_token)
    roles = @params.delete(:roles)

    token_data = JWT.decode(password_token, 'User_PW_S3cr3t', true, algorithm: 'HS256')
    user = User.new(@params)
    user.password = token_data[0]['password']
    user.password_confirmation = token_data[0]['password']
    roles.each do |role|
      user.system_administrator = true if role == 'system_administrator'
      user.teacher = true if role == 'teacher'
      user.student = true if role == 'student'
      user.counselor = true if role == 'counselor'
      user.school_administrator = true if role == 'school_administrator'
    end
    # user = set_role_booleans(user, roles)
    # user.set_unique_username
    user.username = "#{user.first_name}_#{rand(100000).to_s}"
    puts @params.inspect.red
    puts user.inspect.yellow
    user.save!
    user
  end

  private

  def set_role_booleans(user, roles)
    roles.each do |role|
      user.system_administrator = true if role == 'system_administrator'
      user.teacher = true if role == 'teacher'
      user.student = true if role == 'student'
      user.counselor = true if role == 'counselor'
      user.school_administrator = true if role == 'school_administrator'
    end

    user
  end
end
