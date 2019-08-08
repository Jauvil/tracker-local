# error_handling_spec.rb
require 'rails_helper'


describe "Error Handling", js:true do
  before (:each) do
    @school = FactoryBot.create :school
  end

  describe "as teacher" do
    before do
      @teacher = FactoryBot.create :teacher, school: @school
      sign_in(@teacher)
      @home_page = "/teachers/#{@teacher.id}"
    end
    it { no_dashboard_loop }
  end

  describe "as school administrator" do
    before do
      @school_administrator = FactoryBot.create :school_administrator, school: @school
      sign_in(@school_administrator)
      @home_page = "/school_administrators/#{@school_administrator.id}"
    end
    it { no_dashboard_loop }
  end

  describe "as researcher" do
    before do
      @researcher = FactoryBot.create :researcher
      sign_in(@researcher)
      # set_users_school(@school)
      @home_page = "/researchers/#{@researcher.id}"
    end
    it { no_dashboard_loop }
  end

  describe "as system administrator" do
    before do
      @system_administrator = FactoryBot.create :system_administrator
      sign_in(@system_administrator)
      # set_users_school(@school)
      @home_page = "/system_administrators/#{@system_administrator.id}"
    end
    it { no_dashboard_loop }
  end

  describe "as student" do
    before do
      @student = FactoryBot.create :student, school: @school
      sign_in(@student)
      @home_page = "/students/#{@student.id}"
    end
    it { no_dashboard_loop }
  end

  describe "as parent" do
    before do
      @student = FactoryBot.create :student, school: @school
      sign_in(@student.parent)
      @home_page = "/parents/#{@student.parent.id}"
    end
    it { no_dashboard_loop }
  end

  ##################################################
  # test methods

  def no_dashboard_loop
    # try to go invalid student page
    visit student_path('9999999999')
    assert_equal('/500', current_path)
  end # no_dashboard_loop
end