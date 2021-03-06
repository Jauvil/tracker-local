class Api::V1::TrackerPagesController < Api::V1::BaseController
  include Sso::Constants

  def index
    email = decoded_token['email']
    @user = User.find_by_email(email)

    if @user
      if @user.system_administrator
        render json: system_administrator_response
      else
        @teacher = Teacher.find(@user.id)
        if @teacher
          render json: teacher_response
        else
          render json: { success: false, message: 'user has no sections' }
        end
      end
    else
      render json: { success: false, message: 'no user found' }
    end
  end

  private

  def system_administrator_response
    @evidence_types = []
    evidence_types
    return {
      success: true,
      evidence_types: @evidence_types
    }
  end

  def teacher_response
    @sections = []
    @evidence_types = []
    teacher_sections
    evidence_types
    return {
      success: true,
      message: 'tracker pages links',
      sections: @sections,
      tracker_link: secrets['my_url'] + "/teachers/#{@teacher.id}",
      evidence_types: @evidence_types
    }
  end

  def decoded_token
    token = params.keys[0]
    begin
      token_data = JWT.decode(token, secrets['json_api_key'], true, algorithm: 'HS256')
      token_data[0]
    rescue JWT::DecodeError
      nil
    end
  end

  def teacher_sections
    @teacher.sections.each do |section|
      @sections.push({
        section_name: section.name,
        section_id: section.id,
        section_line_number: section.line_number
      })
    end
  end

  def evidence_types
    EvidenceType.all.each do |evidence_type|
      @evidence_types.push({
        id: evidence_type.id,
        name: evidence_type.name
      })
    end
  end

end
