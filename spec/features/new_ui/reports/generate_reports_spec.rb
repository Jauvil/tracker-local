# generate_reports_spec.rb
require 'rails_helper'


describe "Generate Reports", js:true do
  before (:each) do
    @section = FactoryBot.create :section
    @school = @section.school
    @teacher = FactoryBot.create :teacher, school: @school
    @teacher_deact = FactoryBot.create :teacher, school: @school, active: false
    load_test_section(@section, @teacher)

  end

  describe "as teacher" do
    before do
      sign_in(@teacher)
      @home_page = "/teachers/#{@teacher.id}"
    end
    it { has_valid_generate_reports(:teacher) }
  end

  describe "as school administrator" do
    before do
      @school_administrator = FactoryBot.create :school_administrator, school: @school
      sign_in(@school_administrator)
      @home_page = "/school_administrators/#{@school_administrator.id}"
    end
    it { has_valid_generate_reports(:school_administrator) }
  end

  describe "as researcher" do
    before do
      @researcher = FactoryBot.create :researcher
      sign_in(@researcher)
      set_users_school(@school)
      @home_page = "/researchers/#{@researcher.id}"
    end
    it { has_valid_generate_reports(:researcher) }
  end

  describe "as system administrator" do
    before do
      @system_administrator = FactoryBot.create :system_administrator
      sign_in(@system_administrator)
      set_users_school(@school)
      @home_page = "/system_administrators/#{@system_administrator.id}"
    end
    it { has_valid_generate_reports(:system_administrator) }
  end

  describe "as student" do
    before do
      sign_in(@student)
      @home_page = "/students/#{@student.id}"
    end
    it { has_no_reports }
  end

  describe "as parent" do
    before do
      sign_in(@student.parent)
      @home_page = "/parents/#{@student.parent.id}"
    end
    it { has_no_reports }
  end

  ##################################################
  # test methods

  def has_no_reports
    # should not have a link to generate reports
    page.should_not have_css("#side-reports")
    page.should_not have_css("a", text: 'Generate Reports')
    # should fail when going to generate reports page directly
    visit new_generate_path
    assert_equal(@home_page, current_path)
    page.should_not have_content('Internal Server Error')
    # should fail when running attendance report directly
    visit attendance_report_attendances_path
    assert_equal(@home_page, current_path)
    page.should_not have_content('Internal Server Error')
    within("#breadcrumb-flash-msgs") do
      page.should have_content('You are not authorized to access this page.')
    end
  end

  def has_valid_generate_reports(role)
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')


    # select report uses bootstrap, and rspec3 and capybara cannot scroll the bootstrap elements into view.
    # thus cannot: # select('Attendance Report', from: "generate-type")
    # need to click on the fieldset to open up the list of reports
    # then click on the report in the bootstrap list of reports

    # make sure all reports are available to user based upon their role.
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    within("ul#select2-results-2") do
      if [:system_administrator].include?(role)
        # only system administrators can see these
      end
      if [:system_administrator, :school_administrator].include?(role)
        # only administrators can see these
        page.should have_css("li div", text: 'Tracker Usage / Activity')
        page.should have_css("li div", text: 'Student Information Handout By Grade Level')
        page.should have_css("li div", text: 'Proficiency Bars by Student')
        page.should have_css("li div", text: 'Proficiency Bars By Subject')
        page.should have_css("li div", text: 'Progress Meters by Subject')
        page.should have_css("li div", text: 'Report Cards')
      end
      if [:system_administrator, :school_administrator, :teacher].include?(role)
        # Teachers and administrators can see these
        page.should have_css("li div", text: 'Attendance Report')
        page.should have_css("li div", text: 'Student Attendance Detail Report')
        page.should have_css("li div", text: 'Student Information Handout')
      end
      # all staff can see these
      page.should have_css("li div", text: 'Progress Reports')
      page.should have_css("li div", text: 'Section Summary by Learning Outcome')
      page.should have_css("li div", text: 'Section Summary by Student')
      page.should have_css("li div", text: 'Not Yet Proficient by Learning Outcome')
      page.should have_css("li div", text: 'Not Yet Proficient by Student')

    end

    # check all reports have the correct questions, and then the report is properly generated
    # To Do - finish adding all reports
    if [:system_administrator].include?(role)
      # only system administrators can see these
    end
    if [:system_administrator, :school_administrator].include?(role)
      can_run_proficiency_bars_by_student
    end
    if [:system_administrator, :school_administrator, :teacher].include?(role)
    end

  end # has_valid_generate_reports

  def can_run_proficiency_bars_by_student
    # page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: 'Proficiency Bars by Student').click
    within("#page-content form#new_generate") do
      # confirm correct input fields for attendance report are presented
      find("select#generate-type").value.should == "proficiency_bars_by_student"
      page.should_not have_css('fieldset#ask-subjects', visible: true)
      page.should_not have_css('fieldset#ask-subject-sections', visible: true)
      page.should_not have_css('fieldset#ask-grade-level', visible: true)
      page.should_not have_css('fieldset#ask-section', visible: true)
      page.should_not have_css('fieldset#ask-los', visible: true)
      page.should_not have_css('fieldset#ask-single-student', visible: true)
      page.should_not have_css('fieldset#ask-marking-periods', visible: true)
      page.should_not have_css('fieldset#ask-date-range', visible: true)
      page.should_not have_css('fieldset#ask-attendance-type', visible: true)
      page.should_not have_css('fieldset#ask-details', visible: true)
      page.should_not have_css('fieldset#ask-activity-staff', visible: true)
      page.should_not have_css('fieldset#ask-activity-students', visible: true)
      page.should_not have_css('fieldset#ask-activity-parents', visible: true)
      find("button", text: 'Generate').click
    end
    assert_equal(students_report_path('proficiency_bar_chart'), current_path)
    page.should_not have_content('Internal Server Error')

    within("#page-content h2.h1") do
      page.should have_content("Proficiency Bar Charts By Student")
    end

  end

end
