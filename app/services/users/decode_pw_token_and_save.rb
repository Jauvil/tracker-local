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
    token_data = JWT.decode(password_token, 'User_PW_S3cr3t', true, algorithm: 'HS256')
    user = User.new(@params)
    user.password = token_data[0]['password']
    user.password_confirmation = token_data[0]['password']
    user.save
    user
  end
end
