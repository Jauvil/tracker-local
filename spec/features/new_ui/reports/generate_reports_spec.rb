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
    it { has_valid_generate_reports }
  end

  describe "as school administrator" do
    before do
      @school_administrator = FactoryBot.create :school_administrator, school: @school
      sign_in(@school_administrator)
      @home_page = "/school_administrators/#{@school_administrator.id}"
    end
    it { has_valid_generate_reports }
  end

  describe "as researcher" do
    before do
      @researcher = FactoryBot.create :researcher
      sign_in(@researcher)
      set_users_school(@school)
      @home_page = "/researchers/#{@researcher.id}"
    end
    it { has_no_attendance_report }
  end

  describe "as system administrator" do
    before do
      @system_administrator = FactoryBot.create :system_administrator
      sign_in(@system_administrator)
      set_users_school(@school)
      @home_page = "/system_administrators/#{@system_administrator.id}"
    end
    it { has_valid_generate_reports }
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
    within('head title') do
      page.should_not have_content('Internal Server Error')
    end
  end

  def has_no_attendance_report
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')
    within("#page-content") do
      within('form#new_generate') do
        page.should have_css('fieldset#ask-subjects', visible: false)
        page.should have_css('fieldset#ask-date-range', visible: false)
        page.should have_selector("select#generate-type")

        # confirm attendance report options are not available
        page.should have_css("select#generate-type")
        page.should_not have_css("select#generate-type option#attendance_report")
      end
    end
  end

  def has_valid_generate_reports
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')
    within("#page-content") do
      within('form#new_generate') do
        page.should have_css('fieldset#ask-subjects', visible: false)
        page.should have_css('fieldset#ask-date-range', visible: false)
        page.should have_selector("select#generate-type")

        # confirm correct input fields for attendance report are presented
        select('Attendance Report', from: "generate-type")
        find("select#generate-type").value.should == "attendance_report"
        page.should have_css('fieldset#ask-subjects', visible: true)
        page.should have_css('fieldset#ask-date-range', visible: true)

      end
    end
  end # has_valid_generate_reports

  def has_valid_attendance_report
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')
    within("#page-content") do
      within('form#new_generate') do
        page.should have_css('fieldset#ask-subjects', visible: false)
        page.should have_css('fieldset#ask-date-range', visible: false)
        page.should have_selector("select#generate-type")
        select('Attendance Report', from: "generate-type")
        find("select#generate-type").value.should == "attendance_report"
        page.should have_css('fieldset#ask-subjects', visible: true)
        page.should have_css('fieldset#ask-date-range', visible: true)
        find("button", text: 'Generate').click
      end
    end
    # should return back to generate reports page with required fields errors
    assert_equal("/generates", current_path)
    page.should have_content('Generate Reports')
    page.should_not have_content('Internal Server Error')
    within("#page-content") do
      within('form#new_generate') do

        # confirm that the required fields errors are displaying
        find("select#generate-type").value.should == "attendance_report"
        page.should have_css('fieldset#ask-subjects', visible: true)
        page.should have_css('fieldset#ask-date-range', visible: true)
        within("fieldset#ask-subjects span.ui-error") do
          page.should have_content('is a required field')
        end
        # within("fieldset#ask-date-range") do
        #   page.should have_css('span.ui-error', text: '["is a required field"]')
        # end

        # fill in values for the attendance report
        select(@section.subject.name, from: 'subject')
        page.fill_in 'start-date', :with => '2015-06-02'
        page.fill_in 'end-date', :with => '2015-06-08'


        # submit the request for the attendance report
        find("button", text: 'Generate').click
      end
    end

    assert_equal(attendance_report_attendances_path(), current_path)
    page.should_not have_content('Internal Server Error')

    within("#page-content") do
      within('.report-body') do

        page.should have_content("Attendance Report")
        # within('table thead.table-title') do
        #   page.should have_content('ID')
        #   page.should have_content('Student Name')
        #   page.should have_content(@at_tardy.description)
        #   page.should have_content(@at_absent.description)
        #   page.should have_content('Comment')
        # end
      end
    end


  end # def has_valid_attendance_report


end
