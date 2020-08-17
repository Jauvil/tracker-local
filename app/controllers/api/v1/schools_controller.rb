class Api::V1::SchoolsController < Api::V1::BaseController
  def index
    schools = School.all
    render json: { success: true, data: schools }
  end
end