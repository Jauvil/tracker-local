# generate_attendance-report_spec.rb
require 'rails_helper'


describe "Generate Attendance Report", js:true do
  before (:each) do

    create_and_load_arabic_model_school

    # @school1
    @school1 = FactoryBot.create :school_current_year, :arabic
    @teacher1 = FactoryBot.create :teacher, school: @school1
    @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
    @section1_1 = FactoryBot.create :section, subject: @subject1
    @discipline = @subject1.discipline
    load_test_section(@section1_1, @teacher1)


    @subject2 = FactoryBot.create :subject, subject_manager: @teacher1
    @section2_1 = FactoryBot.create :section, subject: @subject2
    @section2_2 = FactoryBot.create :section, subject: @subject2
    @discipline2 = @subject2.discipline

    @teaching_assignment2_1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section2_1
    @teaching_assignment2_2 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section2_2

    @enrollment2_1_2 = FactoryBot.create :enrollment, section: @section2_1, student: @student2
    @enrollment2_1_3 = FactoryBot.create :enrollment, section: @section2_1, student: @student3
    @enrollment2_2_4 = FactoryBot.create :enrollment, section: @section2_2, student: @student4
    @enrollment2_2_5 = FactoryBot.create :enrollment, section: @section2_2, student: @student5

    @at_tardy = FactoryBot.create :attendance_type, description: "Tardy", school: @school1
    @at_absent = FactoryBot.create :attendance_type, description: "Absent", school: @school1
    @at_deact = FactoryBot.create :attendance_type, description: "Deactivated", school: @school1, active: false

    # 9/1 has tardy and absent
    # in subject 1
    FactoryBot.create :attendance,
      section: @section1_1,
      student: @student,
      attendance_type: @at_tardy,
      attendance_date: Date.new(2015,9,1)
      FactoryBot.create :attendance,
      section: @section1_1,
      student: @student2,
      attendance_type: @at_absent,
      attendance_date: Date.new(2015,9,1)

    # 9/2 has tardy and absent
    # in subject 1
    FactoryBot.create :attendance,
      section: @section1_1,
      student: @student,
      attendance_type: @at_tardy,
      attendance_date: Date.new(2015,9,2)
      FactoryBot.create :attendance,
      section: @section1_1,
      student: @student2,
      attendance_type: @at_deact,
      attendance_date: Date.new(2015,9,2)

    # two sections of subject2 across two days
    FactoryBot.create :attendance,
      section: @section2_1,
      student: @student2,
      attendance_type: @at_absent,
      attendance_date: Date.new(2015,9,1)
      FactoryBot.create :attendance,
      section: @section2_1,
      student: @student3,
      attendance_type: @at_tardy,
      attendance_date: Date.new(2015,9,1)
      FactoryBot.create :attendance,
      section: @section2_1,
      student: @student2,
      attendance_type: @at_absent,
      attendance_date: Date.new(2015,9,2)
      FactoryBot.create :attendance,
      section: @section2_1,
      student: @student3,
      attendance_type: @at_tardy,
      attendance_date: Date.new(2015,9,2)
      FactoryBot.create :attendance,
      section: @section2_2,
      student: @student4,
      attendance_type: @at_absent,
      attendance_date: Date.new(2015,9,2)
      FactoryBot.create :attendance,
      section: @section2_2,
      student: @student5,
      attendance_type: @at_tardy,
      attendance_date: Date.new(2015,9,2)

  end

  describe "as teacher" do
    before do
      sign_in(@teacher1)
      @err_page = "/teachers/#{@teacher1.id}"
    end
    it { has_valid_attendance_report(true) }
  end

  describe "as school administrator" do
    before do
      @school_administrator = FactoryBot.create :school_administrator, school: @school1
      sign_in(@school_administrator)
      @err_page = "/school_administrators/#{@school_administrator.id}"
    end
    it { has_valid_attendance_report(true) }
  end

  describe "as researcher" do
    before do
      @researcher = FactoryBot.create :researcher
      sign_in(@researcher)
      set_users_school(@school1)
      @err_page = "/researchers/#{@researcher.id}"
    end
    it { has_no_attendance_report }
  end

  describe "as system administrator" do
    before do
      @system_administrator = FactoryBot.create :system_administrator
      sign_in(@system_administrator)
      set_users_school(@school1)
      @err_page = "/system_administrators/#{@system_administrator.id}"
    end
    it { has_valid_attendance_report(true) }
  end

  describe "as student" do
    before do
      sign_in(@student)
      @err_page = "/students/#{@student.id}"
    end
    it { has_no_reports }
  end

  describe "as parent" do
    before do
      sign_in(@student.parent)
      @err_page = "/parents/#{@student.parent.id}"
    end
    it { has_no_reports }
  end

  ##################################################
  # test methods

  def has_no_reports
    # students and parents should not have a link to generate reports
    page.should_not have_css("#side-reports")
    page.should_not have_css("a", text: 'Generate Reports')
    # should fail when going to generate reports page directly
    visit new_generate_path
    assert_equal(@err_page, current_path)
    page.should_not have_content('Internal Server Error')
    # should fail when running attendance report directly
    visit attendance_report_attendances_path
    assert_equal(@err_page, current_path)
    page.should_not have_content('Internal Server Error')
    within("#breadcrumb-flash-msgs") do
      page.should have_content('You are not authorized to access this page.')
    end
  end

  def has_no_attendance_report
    # researcher should have a link to generate reports
    page.should have_css("#side-reports")
    page.should have_css("a", text: 'Generate Reports')
    # should not fail when going to generate reports page directly
    visit new_generate_path
    assert_not_equal(@err_page, current_path)
    page.should_not have_content('Internal Server Error')
    # should fail when running attendance report directly
    visit attendance_report_attendances_path
    assert_equal(@err_page, current_path)
    page.should_not have_content('Internal Server Error')
    within("#breadcrumb-flash-msgs") do
      page.should have_content('You are not authorized to access this page.')
    end
  end

  def has_valid_attendance_report(see_names)

    ###############################################################################
    # generate a report with all attendance types used are active (no 'Other' column)
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')
    page.should have_selector("select#generate-type")
    # select report using bootstrap elements (capybara cannot scroll into view the bootstrap options)
    # this does not work anymore: # select('Account Activity Report', from: "generate-type")
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: 'Attendance Report').click
    within("#page-content") do
      within('form#new_generate') do
        find("select#generate-type").value.should == "attendance_report"
        page.should have_css('fieldset#ask-subjects', visible: true)
        page.should have_css('fieldset#ask-date-range', visible: true)
        page.should have_css('fieldset#ask-attendance-type', visible: true)
        page.should_not have_css('fieldset#ask-details', visible: true)
        page.fill_in 'start-date', :with => '2015-06-02' # note: generates an invalid date in datepicker
        page.fill_in 'end-date', :with => '2015-06-08' # note: generates an invalid date in datepicker
        find("button", text: 'Generate').click
      end
    end

    # should return back to generate reports page with required fields errors
    page.should have_content('Generate Reports')
    page.should_not have_content('Internal Server Error')
    within("#page-content") do
      within('form#new_generate') do

        # confirm that the required fields errors are displaying
        find("#select2-chosen-2").text.should == "Attendance Report"
        page.should have_css('fieldset#ask-subjects', visible: true)
        page.should have_css('fieldset#ask-date-range', visible: true)
        within("fieldset#ask-subjects") do
          page.should have_content('is a required field')
        end
        # not consistently displaying
        within("fieldset#ask-date-range") do
          page.should have_content('was an invalid value')
        end
      end
    end
    # select report using bootstrap elements (capybara cannot scroll into view the bootstrap options)
    # this does not work anymore: # select(@subject1.name, from: 'subject')
    page.find("form#new_generate fieldset", text: 'Select Subject:', wait: 5).click
    page.find("ul#select2-results-3 li div", text: @subject1.name).click
    within("#page-content") do
      within('form#new_generate') do
        # page.fill_in 'start-date', :with => '2015-06-02'
        # page.fill_in 'end-date', :with => '2015-06-08'
        # need to use javascript to fill in datepicker value
        page.execute_script("$('#start-date').val('2015-09-01')")
        page.execute_script("$('#end-date').val('2015-09-01')")

        # submit the request for the attendance report
        find("button", text: 'Generate').click
      end
    end

    assert_equal(attendance_report_attendances_path(), current_path)
    page.should_not have_content('Internal Server Error')

    within("#page-content") do
      within('.report-body') do

        page.should have_content("Attendance Report")
        within('table thead.table-title') do
          page.should have_content('ID')
          page.should have_content('Student Name')
          page.should have_content(@at_tardy.description)
          page.should have_content(@at_absent.description)
          page.should_not have_content('Other')
        end
        within("table tbody.tbody-header tr[data-student-id='#{@student.id}']") do
          page.should have_content(@enrollments[0].student.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('0')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('1')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        within("table tbody.tbody-header tr[data-student-id='#{@student2.id}']") do
          page.should have_content(@enrollments[1].student.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('1')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('0')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        # should have inactive types dates listed at bottom of report
        page.should_not have_content('02 Sep 2015')
        # confirm link to student goes to student
        page.should have_css("table tbody.tbody-header tr[data-student-id='#{@student.id}'] a[href='/students/#{@student.id}']", wait: 5)
      end # within('.report-body')
    end # within("#page-content")


    ###############################################################################
    # generate a report with a deactivated attendance type showing 'Other' column
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')
    page.should have_selector("select#generate-type")
    # select report using bootstrap elements (capybara cannot scroll into view the bootstrap options)
    # this does not work anymore: # select('Account Activity Report', from: "generate-type")
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: 'Attendance Report').click
    # this does not work anymore: # select(@subject1.name, from: 'subject')
    page.find("form#new_generate fieldset", text: 'Select Subject:', wait: 5).click
    page.find("ul#select2-results-3 li div", text: @subject1.name).click
    within("#page-content") do
      within('form#new_generate') do
        # javascript to fill in datepicker value
        page.execute_script("$('#start-date').val('2015-09-02')")
        page.execute_script("$('#end-date').val('2015-09-02')")
        # submit the request for the attendance report
        find("button", text: 'Generate').click
      end
    end

    assert_equal(attendance_report_attendances_path(), current_path)
    page.should_not have_content('Internal Server Error')

    within("#page-content") do
      within('.report-body') do

        page.should have_content("Attendance Report")
        within('table thead.table-title') do
          page.should have_content('ID')
          page.should have_content('Student Name')
          page.should have_content(@at_tardy.description)
          page.should have_content(@at_absent.description)
          page.should have_content('Other')
        end
        within("table tbody.tbody-header tr[data-student-id='#{@enrollments[0].student.id}']") do
          page.should have_content(@enrollments[0].student.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('0')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('1')
          end
          within("td[data-type-id='9999999']") do
            page.should have_content('0')
          end
        end
        within("table tbody.tbody-header tr[data-student-id='#{@enrollments[1].student.id}']") do
          page.should have_content(@enrollments[1].student.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('0')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('0')
          end
          within("td[data-type-id='9999999']") do
            page.should have_content('1')
          end
        end
        # should have inactive types dates listed at bottom of report
        page.should have_content('02 Sep 2015')
      end
    end

    ###############################################################################
    # generate a report for subject 2
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')
    page.should have_selector("select#generate-type")
    # select report using bootstrap elements (capybara cannot scroll into view the bootstrap options)
    # this does not work anymore: # select('Account Activity Report', from: "generate-type")
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: 'Attendance Report').click
    # this does not work anymore: # select(@section2_1.subject.name, from: 'subject')
    page.find("form#new_generate fieldset", text: 'Select Subject:', wait: 5).click
    page.find("ul#select2-results-3 li div", text: @section2_1.subject.name).click
    within("#page-content") do
      within('form#new_generate') do
        # javascript to fill in datepicker value
        page.execute_script("$('#start-date').val('2015-09-01')")
        page.execute_script("$('#end-date').val('2015-09-02')")
        # submit the request for the attendance report
        find("button", text: 'Generate').click
      end
    end

    assert_equal(attendance_report_attendances_path(), current_path)
    page.should_not have_content('Internal Server Error')

    within("#page-content") do
      within('.report-body') do

        page.should have_content("Attendance Report")
        within('table thead.table-title') do
          page.should have_content('ID')
          page.should have_content('Student Name')
          page.should have_content(@at_tardy.description)
          page.should have_content(@at_absent.description)
          page.should_not have_content('Other')
        end
        within("table tbody.tbody-header tr[data-student-id='#{@student2.id}']") do
          page.should have_content(@student2.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('2')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('0')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        within("table tbody.tbody-header tr[data-student-id='#{@student3.id}']") do
          page.should have_content(@student3.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('0')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('2')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        within("table tbody.tbody-header tr[data-student-id='#{@student4.id}']") do
          page.should have_content(@student4.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('1')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('0')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        within("table tbody.tbody-header tr[data-student-id='#{@student5.id}']") do
          page.should have_content(@student5.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('0')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('1')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        # should have inactive types dates listed at bottom of report
        page.should_not have_content('02 Sep 2015')
      end
    end

    ###############################################################################
    # generate a report for subject 2, section @section2_1
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')
    page.should have_selector("select#generate-type")
    # select report using bootstrap elements (capybara cannot scroll into view the bootstrap options)
    # this does not work anymore: # select('Account Activity Report', from: "generate-type")
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: 'Attendance Report').click
    # this does not work anymore: # select(@section2_1.subject.name, from: 'subject')
    page.find("form#new_generate fieldset", text: 'Select Subject:', wait: 5).click
    page.find("ul#select2-results-3 li div", text: @section2_1.subject.name).click
    # this does not work anymore: # select(@section2_1.section_name, from: 'subject-section-select')
    page.find("form#new_generate fieldset", text: 'Section:', wait: 5).click
    page.find("ul#select2-results-4 li div", text: @section2_1.section_name).click
    within("#page-content") do
      within('form#new_generate') do
        # javascript to fill in datepicker value
        page.execute_script("$('#start-date').val('2015-09-02')")
        page.execute_script("$('#end-date').val('2015-09-02')")
        # submit the request for the attendance report
        find("button", text: 'Generate').click
      end
    end

    assert_equal(attendance_report_attendances_path(), current_path)
    page.should_not have_content('Internal Server Error')

    within("#page-content") do
      within('.report-body') do

        page.should have_content("Attendance Report")
        within('table thead.table-title') do
          page.should have_content('ID')
          page.should have_content('Student Name')
          page.should have_content(@at_tardy.description)
          page.should have_content(@at_absent.description)
          page.should_not have_content('Other')
        end
        within("table tbody.tbody-header tr[data-student-id='#{@student2.id}']") do
          page.should have_content(@student2.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('1')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('0')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        within("table tbody.tbody-header tr[data-student-id='#{@student3.id}']") do
          page.should have_content(@student3.full_name) if see_names
          within("td[data-type-id='#{@at_absent.id}']") do
            page.should have_content('0')
          end
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('1')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        page.should_not have_css("table tbody.tbody-header tr[data-student-id='#{@student4.id}']")
        page.should_not have_css("table tbody.tbody-header tr[data-student-id='#{@student5.id}']")
        # should have inactive types dates listed at bottom of report
        page.should_not have_content('02 Sep 2015')
      end
    end

    ###############################################################################
    # generate a report for subject 2, section @section2_1
    page.should have_css("#side-reports a", text: 'Generate Reports')
    find("#side-reports a", text: 'Generate Reports').click
    page.should have_content('Generate Reports')
    page.should have_selector("select#generate-type")
    # select report using bootstrap elements (capybara cannot scroll into view the bootstrap options)
    # this does not work anymore: # select('Account Activity Report', from: "generate-type")
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: 'Attendance Report').click
    # this does not work anymore: # select(@section2_1.subject.name, from: 'subject')
    page.find("form#new_generate fieldset", text: 'Select Subject:', wait: 5).click
    page.find("ul#select2-results-3 li div", text: @section2_1.subject.name).click
    # this does not work anymore: # select(@section2_1.section_name, from: 'subject-section-select')
    page.find("form#new_generate fieldset", text: 'Section:', wait: 5).click
    page.find("ul#select2-results-4 li div", text: @section2_1.section_name).click
    # this does not work anymore: # select(@at_tardy.description, from: "attendance-type-select")
    page.find("form#new_generate fieldset", text: 'Attendance Type:', wait: 5).click
    page.find("ul#select2-results-9 li div", text: @at_tardy.description).click
    within("#page-content") do
      within('form#new_generate') do
        # javascript to fill in datepicker value
        page.execute_script("$('#start-date').val('2015-09-01')")
        page.execute_script("$('#end-date').val('2015-09-02')")
        # page.find('#date-details-box').set(true)
        # submit the request for the attendance report
        find("button", text: 'Generate').click
      end
    end

    assert_equal(attendance_report_attendances_path(), current_path)
    page.should_not have_content('Internal Server Error')

    within("#page-content") do
      within('.report-body') do

        page.should have_content("Attendance Report")
        within('table thead.table-title') do
          page.should have_content('ID')
          page.should have_content('Student Name')
          page.should have_content(@at_tardy.description)
          page.should_not have_content(@at_absent.description)
          page.should_not have_content('Other')
        end
        page.should_not have_css("table tbody.tbody-header tr[data-student-id='#{@student2.id}']")
        within("table tbody.tbody-header tr[data-student-id='#{@student3.id}']") do
          page.should have_content(@student3.full_name) if see_names
          page.should_not have_css("td[data-type-id='#{@at_absent.id}']")
          within("td[data-type-id='#{@at_tardy.id}']") do
            page.should have_content('2')
          end
          page.should_not have_css("td[data-type-id='9999999']")
        end
        page.should_not have_css("table tbody.tbody-header tr[data-student-id='#{@student4.id}']")
        page.should_not have_css("table tbody.tbody-header tr[data-student-id='#{@student5.id}']")
        # should have inactive types dates listed at bottom of report
        page.should_not have_content('02 Sep 2015')
      end
    end

  end # def has_valid_attendance_report


end
