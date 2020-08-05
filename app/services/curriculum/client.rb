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

  def self.learning_outcomes(jwt_token, tree_type_id, subject_id)
    klass_instance = new(jwt_token, tree_type_id, subject_id)
    klass_instance.learning_outcomes
  end

  def initialize(jwt_token, tree_type_id=nil, subject_id=nil)
    @jwt_token = jwt_token
    @tree_type_id = tree_type_id
    @subject_id = subject_id
    @base_url = secrets['curriculum_url']
  end

  def curriculums
    response = HTTParty.get(@base_url + '/api/v1/curriculums', headers: headers).parsed_response
    if response['success']
      return Curriculum::ResponseParser.parse_curriculums(response['curriculums'])
    end
    response
  end

  def subjects
    body = { tree_type_id: @tree_type_id }.to_json
    response = HTTParty.get(@base_url + '/api/v1/curriculum_subjects', body: body, headers: headers).parsed_response
    if response['success']
      return Curriculum::ResponseParser.parse_curriculum_subjects(response['subjects'])
    end
    response
  end
  
  def learning_outcomes
    body = { subject_id: @subject_id, tree_type_id: @tree_type_id }.to_json
    response = HTTParty.get(@base_url + '/api/v1/subject_learning_outcomes', body: body, headers: headers).parsed_response
    if response['success']
      return Curriculum::ResponseParser.parse_subject_learning_outcomes(response['learning_outcomes'])
    end
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

