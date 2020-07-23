module Users
  class UpdatePasswordService
    def self.perform(user, params, school, config)
      obj = new(user, params, school, config)
      obj.run
    end

    def initialize(user, params, school, config)
      @user = user
      @params = params
      @school = school
      @config = config
    end

    def run
      if @user.update_attributes(@params)
        remove_temporary_password
        UserMailer.changed_user_password(@user, @school, @config).deliver_now
        true
      else
        false
      end
    end

    private

    def remove_temporary_password
      unless @user.temporary_password == @params[:password]
        @user.temporary_password = nil
        @user.save
      end
    end
  end
end
