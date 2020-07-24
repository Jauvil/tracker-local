class Api::V1::TrackerPagesController < ApplicationController

  def index
    email = decoded_token['email']
    @user = User.find_by_email(email)
    
    if @user
      @teacher = Teacher.find(@user.id)
      sections = []
      if @teacher 
        @teacher.sections.each do |section|
          sections.push({ 
            section_name: section.name,
            section_id: section.id,
            section_line_number: section.line_number
          })
        end
        render json: {
          success: true, 
          message: 'tracker pages links', 
          sections: sections
        }
      else
        render json: { success: false, message: 'user has no sections' }
      end
    else
      render json: { success: false, message: 'no user found' }
    end
  end

  private

  def decoded_token
    token = params.keys[0]
    begin
      token_data = JWT.decode(token, JWT_PASSWORD, true, algorithm: 'HS256')
      token_data[0]
    rescue JWT::DecodeError
      nil
    end
  end

end