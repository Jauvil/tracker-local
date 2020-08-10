module SchoolAdministrators
  class UpdateUserEmail

    class EmailsNotMatchingError < StandardError
      def message
        "Email and email confirmation must match"
      end
    end

    class InvalidEmailError < StandardError
      def message
        "Not a valid email"
      end
    end

    def self.perform(user, user_params)
      obj = new(user, user_params)
      obj.run
    end

    def initialize(user, user_params)
      @user = user
      @params = user_params
    end

    def run
      verify_email_and_confirmation
      @user.update(email: @params[:email])
    end

    private

    def verify_email_and_confirmation
      raise EmailsNotMatchingError unless @params['email'] == @params['email_confirmation']
      raise InvalidEmailError unless @params['email'].match(URI::MailTo::EMAIL_REGEXP)
    end
  end
end
