class Curriculum::Client
  include Sso::Constants

  def self.curriculums(jwt_token)
    klass_instance = new(jwt_token)
    klass_instance.curriculums
  end

  def self.subjects(jwt_token, tree_type_id)
    klass_instance = new(jwt_token, tree_type_id)
    klass_instance.subjects
  end

  def self.subject(jwt_token, tree_type_id, subject_id)
    klass_instance = new(jwt_token, tree_type_id, subject_id)
    klass_instance.subject
  end

  def self.learning_outcomes(jwt_token, tree_type_id, subject_id, grade_band_id)
    klass_instance = new(jwt_token, tree_type_id, subject_id, nil, grade_band_id)
    klass_instance.learning_outcomes
  end

  def self.get_curriculum_versions(jwt_token, curriculum_code)
    klass_instance = new(jwt_token, '', '', curriculum_code)
    klass_instance.get_curriculum_versions
  end

  def initialize(jwt_token, tree_type_id=nil, subject_id=nil, curriculum_code=nil, grade_band_id=nil)
    @jwt_token = jwt_token
    @tree_type_id = tree_type_id
    @subject_id = subject_id
    @curriculum_code = curriculum_code
    @grade_band_id = grade_band_id
    @base_url = secrets['curriculum_url']
  end

  def curriculums
    response = HTTParty.get(@base_url + '/api/v1/curriculums', headers: headers).parsed_response
    if response['success']
      return Curriculum::ResponseParser.parse_curriculums(response)
    end
    response
  end

  def subjects
    body = { tree_type_id: @tree_type_id }.to_json
    response = HTTParty.get(@base_url + '/api/v1/curriculum_subjects', body: body, headers: headers).parsed_response
    if response['success']
      return Curriculum::ResponseParser.parse_curriculum_subjects(response)
    end
    response
  end

  def subject
    body = { tree_type_id: @tree_type_id, subject_id: @subject_id }.to_json
    response = HTTParty.get(@base_url + '/api/v1/curriculum_subjects', body: body, headers: headers).parsed_response
    if response['success']
      return Curriculum::ResponseParser.parse_curriculum_subjects(response)
    end
    response
  end

  def learning_outcomes
    body = { subject_id: @subject_id, tree_type_id: @tree_type_id, grade_band_id: @grade_band_id }.to_json
    response = HTTParty.get(@base_url + '/api/v1/subject_learning_outcomes', body: body, headers: headers).parsed_response
    if response['success']
      return Curriculum::ResponseParser.parse_subject_learning_outcomes(response)
    end
    response
  end

  def get_curriculum_versions
    body = { curriculum_code: @curriculum_code}.to_json
    response = HTTParty.get(@base_url + '/api/v1/curriculum_versions', body: body, headers: headers).parsed_response
    response
  end

  private

  def headers
    { 'Authorization' => @jwt_token,
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end
end

