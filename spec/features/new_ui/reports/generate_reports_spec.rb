# generate_reports_spec.rb
require 'rails_helper'


describe "Generate Reports", js:true do
  before (:each) do
    @section = FactoryBot.create :section
    @subject = @section.subject
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
      find("#side-reports a", text: 'Generate Reports').click
      page.find("form#new_generate fieldset", text: 'Select Report to generate').click
    end
    if [:system_administrator, :school_administrator, :teacher].include?(role)
      can_run_student_information_handout
      can_run_not_yet_proficient_by_student
      validate_progress_report_options
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
      page.should_not have_css('fieldset#ask-sections', visible: true)
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

  def can_run_student_information_handout
      visit new_generate_path
      page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    # page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find_all("ul#select2-results-2 li div", text: 'Student Information Handout').first.click
    within("#page-content form#new_generate") do
      # confirm correct input fields for attendance report are presented
      find("select#generate-type").value.should == "student_info"
      page.should_not have_css('fieldset#ask-subjects', visible: true)
      page.should_not have_css('fieldset#ask-subject-sections', visible: true)
      page.should_not have_css('fieldset#ask-grade-level', visible: true)
      page.should have_css('fieldset#ask-sections', visible: true)
      page.should_not have_css('fieldset#ask-los', visible: true)
      page.should_not have_css('fieldset#ask-single-student', visible: true)
      page.should_not have_css('fieldset#ask-marking-periods', visible: true)
      page.should_not have_css('fieldset#ask-date-range', visible: true)
      page.should_not have_css('fieldset#ask-attendance-type', visible: true)
      page.should_not have_css('fieldset#ask-details', visible: true)
      page.should_not have_css('fieldset#ask-activity-staff', visible: true)
      page.should_not have_css('fieldset#ask-activity-students', visible: true)
      page.should_not have_css('fieldset#ask-activity-parents', visible: true)
    end
    find("button", text: 'Generate').click
    page.should have_css('.ui-error', text: "is a required field")

    page.find("form#new_generate fieldset", text: 'Select Section:', wait: 5).click
    page.find("ul#select2-results-6 li div", text: "#{@subject.name} - #{@section.line_number}", wait: 5).click

    find("button", text: 'Generate').click

    assert_equal(student_info_handout_section_path(@section.id), current_path)
    page.should_not have_content('Internal Server Error')
  end

  def can_run_not_yet_proficient_by_student
    visit new_generate_path
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: "Not Yet Proficient by Student").click
    find("button", text: 'Generate').click
    page.should have_css('.ui-error', text: "is a required field")
    page.find("form#new_generate fieldset", text: 'Select Section').click
    page.find("ul#select2-results-6 li div", match: :first).click
    page.find("form#new_generate fieldset button", text: 'Generate').click
    within("#page-content") do
      page.should_not have_content('Internal Server Error')
      within (".header-block") do
        page.should have_text('Not Yet Proficient by Student')
        page.should have_text('Subject')
        page.should have_text('Sections')
        page.should have_text('Learning Outcomes')
      end
      page.should have_css('#nyp-by-student')
      within ('#nyp-by-student') do
        page.should have_css('.panel')
        Student.all.each do |student| 
          nyp_ratings = student.section_outcomes_by_rating("N", @section.id)
          #if student has NYP ratings for this section, and is still enrolled in the section.
          if nyp_ratings.length > 0 && student.active == true && student.enrollments.where(:section_id => @section.id).length > 0
            page.should have_css("div#stud_#{student.id}")
            within("div#stud_#{student.id}") do 
              nyp_ratings.each do |s_o_r|
                page.should have_content("#{s_o_r[:name]}")
              end
            end
            within(".panel-heading", text:"#{student.first_name} #{student.last_name}") do
              within(".panel-heading-sign") do
                #NYP counter by the students name should match the number of NYP section outcome ratings they have for this section.
                page.should have_content("#{nyp_ratings.length}")
              end
            end
          #else student doesn't have NYP ratings for this section, or is no longer enrolled in the section.
          else
            page.should_not have_css("div#stud_#{student.id}")
            page.should_not have_css("#{student.first_name} #{student.last_name}")
          end

        end
      end 
    end
  end

  
  def validate_progress_report_options
    visit new_generate_path
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: "Progress Report").click
    page.find("form#new_generate fieldset button", text: 'Generate').click
    page.should have_css('.ui-error', text: "is a required field")
  end


end
