# staff_listing_spec.rb
require 'rails_helper'


describe "Student Listing", js:true do
  describe "US System" do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: true
      create_and_load_us_model_school

      @school1 = FactoryBot.create :school, :us
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @teacher2 = FactoryBot.create :teacher, school: @school1, active: false
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline

      load_test_section(@section1_1, @teacher1)

      @section1_2 = FactoryBot.create :section, subject: @subject1
      ta1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_2
      @section1_3 = FactoryBot.create :section, subject: @subject1
      ta2 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_3

      @subject2 = FactoryBot.create :subject, subject_manager: @teacher1
      @section2_1 = FactoryBot.create :section, subject: @subject2
      @section2_2 = FactoryBot.create :section, subject: @subject2
      @section2_3 = FactoryBot.create :section, subject: @subject2
      @discipline2 = @subject2.discipline

      # @enrollment_s2 = FactoryBot.create :enrollment, section: @section2_1, student: @student
      # Assign a deactivated teacher to duplicate the bug can not display student sections if teacher is deactivated.
      @teaching_assignment = FactoryBot.create :teaching_assignment, section: @section2_1, teacher: @teacher2
      @student_grad = FactoryBot.create :student, school: @school1, first_name: 'Student', last_name: 'Graduated', active: false, grade_level: 2017


      # # # :school_prior_year
      @teacher5 = FactoryBot.create :teacher, school: @school1, active: false
      @teacher6 = FactoryBot.create :teacher, school: @school1
      @subject5 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher5
      @section5_1 = FactoryBot.create :section, subject: @subject5
      @section5_2 = FactoryBot.create :section, subject: @subject5
      @section5_3 = FactoryBot.create :section, subject: @subject5
      @teaching_assignment = FactoryBot.create :teaching_assignment, section: @section5_2, teacher: @teacher5
      @discipline = @subject5.discipline
      @student_prev_year = FactoryBot.create :student, school: @school1, first_name: 'Prior', last_name: 'Sections', active: true, grade_level: 2018
      # switch to year 2 for @school1
      @current_school_year = FactoryBot.create :current_school_year, school: @school1
      @school1.school_year_id = @current_school_year.id
      @school1.save

      # # regular setup for Year 2
      @enrollment_s2 = FactoryBot.create :enrollment, section: @section2_1, student: @student_prev_year
      @section6_1 = FactoryBot.create :section, subject: @subject5
      load_test_section(@section6_1, @teacher5)
      @section6_2 = FactoryBot.create :section, subject: @subject5
      @section6_3 = FactoryBot.create :section, subject: @subject5

      # Student enrolled in previous & current sections
      @teacher7 = FactoryBot.create :teacher, school: @school1, active: false
      @subject6 = FactoryBot.create :subject, school: @school1
      @section5_4 = FactoryBot.create :section, subject: @subject6
      @discipline5 = @subject6.discipline
      @student_both = FactoryBot.create :student, school: @school1, first_name: 'Both', last_name: 'Years', active: true, grade_level: 2
      @enrollment_both_1 = FactoryBot.create :enrollment, section: @section2_1, student: @student_both
      @enrollment_both_2 = FactoryBot.create :enrollment, section: @section5_4, student: @student_both
      @teaching_assignment2 = FactoryBot.create :teaching_assignment, section: @section5_4, teacher: @teacher7

    end

    describe "as teacher" do
      before do
        sign_in(@teacher1)
      end
      it { has_valid_student_listing(true, false, false, false) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
      end
      it { has_valid_student_listing(true, true, true, false) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
      end
      it { has_valid_student_listing(false, false, true, true) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
      end
      it { has_valid_student_listing(true, true, true, false) }
    end

    describe "as student" do
      before do
        sign_in(@student)
      end
      it { has_no_student_listing(true) }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
      end
      it { has_no_student_listing(false) }
    end

  end

  describe "Egypt System" do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: false
      create_and_load_arabic_model_school

      @school1 = FactoryBot.create :school, :arabic
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @teacher2 = FactoryBot.create :teacher, school: @school1, active: false
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline

      load_test_section(@section1_1, @teacher1)

      @section1_2 = FactoryBot.create :section, subject: @subject1
      ta1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_2
      @section1_3 = FactoryBot.create :section, subject: @subject1
      ta2 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_3

      @subject2 = FactoryBot.create :subject, subject_manager: @teacher1
      @section2_1 = FactoryBot.create :section, subject: @subject2
      @section2_2 = FactoryBot.create :section, subject: @subject2
      @section2_3 = FactoryBot.create :section, subject: @subject2
      @discipline2 = @subject2.discipline

      # @enrollment_s2 = FactoryBot.create :enrollment, section: @section2_1, student: @student
      # Assign a deactivated teacher to duplicate the bug can not display student sections if teacher is deactivated.
      @teaching_assignment = FactoryBot.create :teaching_assignment, section: @section2_1, teacher: @teacher2
      @student_grad = FactoryBot.create :student, school: @school1, first_name: 'Student', last_name: 'Graduated', active: false, grade_level: 2017


      # # # :school_prior_year
      @teacher5 = FactoryBot.create :teacher, school: @school1, active: false
      @teacher6 = FactoryBot.create :teacher, school: @school1
      @subject5 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher5
      @section5_1 = FactoryBot.create :section, subject: @subject5
      @section5_2 = FactoryBot.create :section, subject: @subject5
      @section5_3 = FactoryBot.create :section, subject: @subject5
      @teaching_assignment = FactoryBot.create :teaching_assignment, section: @section5_2, teacher: @teacher5
      @discipline = @subject5.discipline

      # switch to year 2 for @school1
      @current_school_year = FactoryBot.create :current_school_year, school: @school1
      @school1.school_year_id = @current_school_year.id
      @school1.save
      @student_prev_year = FactoryBot.create :student, school: @school1, first_name: 'Prior', last_name: 'Sections', active: true, grade_level: 2018
      @enrollment_s2 = FactoryBot.create :enrollment, section: @section2_1, student: @student_prev_year
      @section6_1 = FactoryBot.create :section, subject: @subject5
      load_test_section(@section6_1, @teacher5)
      @section6_2 = FactoryBot.create :section, subject: @subject5
      @section6_3 = FactoryBot.create :section, subject: @subject5

      # Student enrolled in previous & current sections
      @teacher7 = FactoryBot.create :teacher, school: @school1, first_name: 'Teacher', last_name: 'Inactive2', active: false
      @subject6 = FactoryBot.create :subject, school: @school1
      @section5_4 = FactoryBot.create :section, subject: @subject6
      @discipline5 = @subject6.discipline
      @student_both = FactoryBot.create :student, school: @school1, first_name: 'Both', last_name: 'Years', active: true, grade_level: 2
      @enrollment_both_1 = FactoryBot.create :enrollment, section: @section5_4, student: @student_both
      @enrollment_both_2 = FactoryBot.create :enrollment, section: @section2_1, student: @student_both
      @teaching_assignment2 = FactoryBot.create :teaching_assignment, section: @section5_4, teacher: @teacher7

    end

    describe "as teacher" do
      before do
        sign_in(@teacher1)
      end
      it { has_valid_student_listing(true, false, false, false) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
      end
      it { has_valid_student_listing(true, true, true, false) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
      end
      it { has_valid_student_listing(false, false, true, true) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
      end
      it { has_valid_student_listing(true, true, true, false) }
    end

    describe "as student" do
      before do
        sign_in(@student)
      end
      it { has_no_student_listing(true) }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
      end
      it { has_no_student_listing(false) }
    end

  end

  ##################################################
  # test methods

  def has_no_student_listing(student)
    page.should_not have_css("#side-students")
    visit students_path
    if student
      all('.student-row').count.should == 1
      page.should have_css("a[data-url='/students/#{@student.id}.js']")
      page.should_not have_css("a[data-url='/students/#{@student.id}/edit.js']")
    else
      all('.student-row').count.should == 0
    end
  end

  def has_valid_student_listing(can_create, can_deactivate, can_see_all, read_only)
    # page.driver.browser.manage.window.maximize
    # # Capybara.page.driver.browser.manage.current_window.maximize
    # # Capybara.page.current_window.maximize

    visit students_path
    assert_equal("/students", current_path)
    within("#page-content") do
      page.should have_content("All Students for: #{@school1.name}")
      page.should have_css("tr#student_#{@student.id}")
      page.should_not have_css("tr#student_#{@student.id}.deactivated")
      within(".titled-table")do
        page.should have_content("Student ID")
        page.should have_content("Family/Last Name")
        page.should have_content("Given/First Name")
        page.should have_content("Student Email")
      end

      within("tr#student_#{@student.id}") do
        page.should have_content("#{@student.last_name}") if can_create
        page.should_not have_content("#{@student.last_name}") if !can_create
        page.should have_content("#{@student.first_name}") if can_create
        page.should_not have_content("#{@student.first_name}") if !can_create
        page.should have_content("#{@student.email}") if can_create
        page.should_not have_content("#{@student.email}") if !can_create
        page.should have_css("i.fa-dashboard")
        page.should have_css("i.fa-check")
        page.should have_css("i.fa-ellipsis-h")
        page.should have_css("i.fa-edit") if can_create
        page.should_not have_css("i.fa-edit") if !can_create
        page.should have_css("i.fa-unlock") if can_deactivate
        # fine tune this, so testing if teachers can unlock students they are assigned to
        # page.should_not have_css("i.fa-unlock") if !can_deactivate
        page.should have_css("i.fa-times-circle") if can_deactivate && @student.active == true
        page.should_not have_css("i.fa-times-circle") if !can_deactivate && @student.active == true
      end
      page.should have_css("tr#student_#{@student_transferred.id}")
      page.should have_css("tr#student_#{@student_transferred.id}.deactivated")
      within("tr#student_#{@student_transferred.id}") do
        page.should have_content("#{@student_transferred.last_name}") if can_create
        page.should_not have_content("#{@student_transferred.last_name}") if !can_create
        page.should have_content("#{@student_transferred.first_name}") if can_create
        page.should_not have_content("#{@student_transferred.first_name}") if !can_create
        page.should have_content("#{@student_transferred.email}") if can_create
        page.should_not have_content("#{@student_transferred.email}") if !can_create
        page.should have_css("i.fa-undo") if can_deactivate && @student_transferred.active == false
        page.should_not have_css("i.fa-undo") if !can_deactivate && @student_transferred.active == false
      end
      # graduated student should be deactivated
      within("tr#student_#{@student_grad.id}.deactivated") do
        page.should have_content("#{@student_grad.last_name}") if can_create
        within('td.user-grade-level') do
          page.should have_content("#{@student_grad.grade_level}") if can_create
        end
      end
    end # within("#page-content") do

    can_see_student_dashboard(@student)
    visit students_path
    assert_equal("/students", current_path)
    can_see_student_sections(@student, @enrollment, @enrollment_s2, can_see_all)
    can_see_prior_year_student_sections(@student_prev_year, @enrollment_s2, can_see_all)
    can_see_both_years_student_sections(@student_both, @enrollment_both_1, @enrollment_both_2, can_see_all)
    visit students_path
    assert_equal("/students", current_path)
    can_reset_student_password(@student) if !read_only # note: tested more completely in password_change_spec.rb
    can_change_student(@student) if !read_only
    visit students_path
    assert_equal("/students", current_path)
    can_create_student(@student) if !read_only
    visit students_path
    assert_equal("/students", current_path)
    can_change_graduate(@student_grad) if !read_only
    can_deactivate_student(@student) if can_deactivate
  end # def has_valid_subjects_listing

  ##################################################
  # supporting tests (called from test methods)

  def can_see_student_dashboard(student)
    within("tr#student_#{student.id}") do
      page.should have_css("i.fa-dashboard")
      page.should have_css("a[href='/students/#{student.id}'] i.fa-dashboard")
      find("a[href='/students/#{student.id}'] i.fa-dashboard").click
    end
    assert_equal("/students/#{student.id}", current_path)
  end

  def can_see_student_sections(student, enrollment, enrollment_s2, can_see_all)
    within("tr#student_#{student.id}") do
      page.should have_css("a[href='/students/#{student.id}/sections_list']")
      find("a[href='/students/#{student.id}/sections_list']").click
    end
    assert_equal("/students/#{student.id}/sections_list", current_path)
    within("#page-content")do
      within(".header-block")do
        within("h2.h1.page-title")do
          page.should have_content("All Sections for student: ")
        end
      end
      within(".table-title")do
        page.should have_content("Subject")
        page.should have_content("Section")
        page.should have_content("Teacher")
      end
      if can_see_all  #can_see_student_sections
        within("tr#enrollment_#{enrollment.id}") do
          page.should have_css("a[href='/enrollments/#{enrollment.id}']")
          find("a[href='/enrollments/#{enrollment.id}']").click
          assert_equal("/enrollments/#{enrollment.id}", current_path)
          visit("/students/#{student.id}/sections_list")
        end
        assert_equal("/students/#{student.id}/sections_list", current_path)
        within("tr#enrollment_#{enrollment.id}") do
          page.should have_css("a[href='/enrollments/#{enrollment.id}']")
          find("a[href='/enrollments/#{enrollment.id}']").click
        end
        assert_equal("/enrollments/#{enrollment.id}", current_path)
      else
        within("tr#enrollment_#{enrollment.id}")do
          # should not see link to tracker page for section not teaching that section
          page.should_not have_css("a[href='/enrollments/#{enrollment.id}']")
          assert_equal("/students/#{student.id}/sections_list", current_path)
        end
      end
      visit students_path
      assert_equal("/students", current_path)
    end
  end

  def can_see_prior_year_student_sections(student_prev_year, enrollment_s2, can_see_all)
    visit students_path
    assert_equal("/students", current_path)
    within("tr#student_#{student_prev_year.id}") do
      page.should have_css("a[href='/students/#{student_prev_year.id}/sections_list']")
      find("a[href='/students/#{student_prev_year.id}/sections_list']").click
    end
    assert_equal("/students/#{student_prev_year.id}/sections_list", current_path)
    within("#page-content")do
      if can_see_all  #can_see_prior_year_student_sections
        page.should have_css("a[href='/enrollments/#{enrollment_s2.id}']")
        find("a[href='/enrollments/#{enrollment_s2.id}']").click
        # sleep 2
        assert_equal("/enrollments/#{enrollment_s2.id}", current_path)
        page.should have_content("Evidence Statistics")
        page.should have_content("Overall Learning Outcome Performance")
      else
        page.should_not have_css("a[href='/enrollments/#{enrollment_s2.id}']")
        assert_equal("/students/#{student_prev_year.id}/sections_list", current_path)
      end
    end
  end

  def can_see_both_years_student_sections(student_both, enrollment_both_1, enrollment_both_2, can_see_all)
    visit students_path
    assert_equal("/students", current_path)
    within("tr#student_#{student_both.id}") do
      page.should have_css("a[href='/students/#{student_both.id}/sections_list']")
      find("a[href='/students/#{student_both.id}/sections_list']").click
    end
    assert_equal("/students/#{student_both.id}/sections_list", current_path)
    within("#page-content")do
      if can_see_all #can_see_both_years_student_sections #1
        page.should have_css("a[href='/enrollments/#{enrollment_both_1.id}']")
        find("a[href='/enrollments/#{enrollment_both_1.id}']").click
        assert_equal("/enrollments/#{enrollment_both_1.id}", current_path)
        page.should have_content("Evidence Statistics")
        page.should have_content("Overall Learning Outcome Performance")
      else
        page.should_not have_css("a[href='/enrollments/#{enrollment_both_1.id}']")
        assert_equal("/students/#{student_both.id}/sections_list", current_path)
      end
      visit students_path
      assert_equal("/students", current_path)
      find("a[href='/students/#{student_both.id}/sections_list']").click
      if can_see_all #can_see_both_years_student_sections #2
        page.should have_css("a[href='/enrollments/#{enrollment_both_2.id}']")
        find("a[href='/enrollments/#{enrollment_both_2.id}']").click
        assert_equal("/enrollments/#{enrollment_both_2.id}", current_path)
        page.should have_content("Evidence Statistics")
        page.should have_content("Overall Learning Outcome Performance")
      else
        page.should_not have_css("a[href='/enrollments/#{enrollment_both_2.id}']")
        assert_equal("/students/#{student_both.id}/sections_list", current_path)
      end
    end
  end

  def can_reset_student_password(student)
    within("tr#student_#{student.id}") do
      page.should have_css("a[data-url='/students/#{student.id}/security.js']")
      find("a[data-url='/students/#{student.id}/security.js']").click
    end
    page.find("#modal_popup h2.h1 strong", text: "Student/Parent Security and Access", wait: 5)
    within("#user_#{student.id}") do
      page.find("a[href='/students/#{student.id}/set_student_temporary_password']", wait: 5).click
    end
    within("#user_#{student.id}.student-temp-pwd") do
      page.should_not have_content('(Reset Password')
    end
    # page.find('div.modal-dialog button').click
    sleep 1
    page.click_button('Close')
  end

  def can_change_student(student)
    puts("+++ student - id: #{student.id}, #{student.inspect}")
    # within("tr#student_#{student.id}") do
    #   page.should have_css("a[data-url='/students/#{student.id}/edit.js']")
    #   page.find("a[data-url='/students/#{student.id}/edit.js']", wait: 5).click
    # end
    page.find("tr#student_#{student.id} a[data-url='/students/#{student.id}/edit.js']", wait: 5).click
    sleep 1
    page.should have_content("Edit Student")
    within("#modal_popup .modal-dialog .modal-content .modal-body") do
      within("form#edit_student_#{student.id}") do
        # page.select(@subject2_1.discipline.name, from: "subject-discipline-id")
        page.fill_in 'student_first_name', :with => 'Fname'
        page.fill_in 'student_last_name', :with => 'Lname'
        # confirm the required flag is displayed (this school has username by email)
        # Test US schools are set with email not required.
        if (ServerConfig.first.try(:allow_subject_mgr) != true)
          page.should have_css("#email span.ui-required")
        else
          page.should_not have_css("#email span.ui-required")
        end
        page.fill_in 'student_email', :with => ''
        # sleep 2
        page.click_button('Save')
      end
    end
    # ensure that blank email gets an error on updates
    visit students_path
    page.find("a[data-url='/students/#{student.id}/edit.js']", wait: 5)
    assert_equal("/students", current_path)
    find("a[data-url='/students/#{student.id}/edit.js']").click
    page.find("form#edit_student_#{student.id}", wait: 5)
    within("#modal_popup .modal-dialog .modal-content .modal-body") do
      within("form#edit_student_#{student.id}") do
        page.find('#student_first_name', wait: 5).set('Fn')
        page.find('#student_last_name', wait: 5).set('Ln')
        #page.should have_css('span.ui-error', text:'Email is required.')
        page.find('#student_email', wait: 5).set('f@a.com')
        page.click_button('Save')
      end
    end
    # Rails.logger.debug("+++ page.should_not have_css edit student")

    # page.should_not have_css("#modal_popup form#edit_student_#{student.id}")
    # sleep 5
    assert_equal("/students", current_path)
    within("tr#student_#{student.id}") do
      page.find("a[data-url='/students/#{student.id}.js']", wait: 5).click
    end
    page.find("h2.h1 strong", text: 'View Student', wait: 5)
    page.should have_content("View Student")
    within("#modal_popup .modal-dialog .modal-content .modal-body") do
      page.should have_content('Fn')
      page.should have_content('Ln')
      page.should have_content('f@a.com')
    end
  end

  def can_create_student(student)
    visit students_path
    # sleep 10
    assert_equal("/students", current_path)
    within("div#page-content") do
      page.should have_css("i.fa-plus-square")
      page.find("a[data-url='/students/new.js']", wait: 5).click
    end

    sleep 1
    page.should have_content("Create New Student")
    within("#modal_popup .modal-dialog .modal-content .modal-body") do
      within("form#new_student") do
        page.find('#student_first_name', wait: 5).set('')
        page.find('#student_last_name', wait: 5).set('')
        # confirm the required flag is displayed (this school has username by email)
        if (ServerConfig.first.try(:allow_subject_mgr) != true)
          page.should have_css("#email span.ui-required")
        else
          page.should_not have_css("#email span.ui-required")
        end
        page.find('#student_email', wait: 5).set('')
        page.find('#student_grade_level', wait: 5).set('4')
        page.click_button('Save')
      end
    end
    sleep 1
    # ensure that blank email gets an error on creates
    # confirm email was saved during create
    page.should have_css("#modal_popup form#new_student")
    within("#modal_popup .modal-dialog .modal-content .modal-body") do
      within("form#new_student") do
        page.should have_css('#first-name span.ui-error', text:'["can\'t be blank"]')
        page.should have_css('#last-name span.ui-error', text:'["can\'t be blank"]')
        # page.should have_css('#email span.ui-error', text:'["Email is required."]')
        # page.should have_css('#grade-level span.ui-error', text:'["Grade Level is invalid"]')
        page.find('#student_first_name').set('NFname')
        page.find('#student_last_name').set('NLname')
        page.find('#student_email').set('new@ba.com')
        page.find('#student_grade_level').set('2')
        page.click_button('Save')
        sleep 2
      end
    end
    assert_equal("/students", current_path)
    page.should_not have_css("#modal_popup form#new_student")
    # expect(page.text).to match(/New\sFname/) # alternate syntax
    page.text.should match(/NFname/)
    # expect(page.text).to match(/New\sLname/) # alternate syntax
    page.text.should match(/NLname/)
    page.should have_content('new@ba.com')

    # confirm username is sch1_new
    student_nodes = all('tbody tr.student-row')
    new_student_id = student_nodes[1][:id].split('_')[1]
    within("tr#student_#{new_student_id}") do
      page.should have_css("a[data-url='/students/#{new_student_id}/security.js']")
      find("a[data-url='/students/#{new_student_id}/security.js']").click
    end
    page.should have_content("Student/Parent Security and Access")
    page.click_button('Close')

    visit students_path
    assert_equal("/students", current_path)
    # ensure username is incremented if a duplicate (e.g. is different after @, etc.)
    within("div#page-content") do
      page.find("a[data-url='/students/new.js']", wait: 5).click
    end

    sleep 1
    page.find("form#new_student", wait: 5)
    within('#modal_popup .header-block h2') do
      page.should have_content("Create New Student")
    end
    within("#modal_popup .modal-dialog .modal-content .modal-body") do
      within("form#new_student") do
        page.find('#student_first_name', wait: 5).set('NFname')
        page.find('#student_last_name', wait: 5).set('NLname')
        page.find('#student_email', wait: 5).set('new@ba.com')
        page.find('#student_grade_level', wait: 5).set('2')
        sleep 1
        page.click_button('Save')
      end
    end
    sleep 1
    assert_equal("/students", current_path)
    page.should_not have_css("#modal_popup form#new_student")
    # expect(page.text).to match(/New\sFname/) # alternate syntax
    page.text.should match(/NFname/)
    # expect(page.text).to match(/New\sLname/) # alternate syntax
    page.text.should match(/NLname/)
    page.should have_content('new@ba.com')
    page.all('td.user-email', text: 'new@ba.com').count.should == 2

    # confirm username is sch1_new2
    student_nodes = all('tbody tr.student-row')
    Rails.logger.debug("*** student_nodes[0][:id]: #{student_nodes[0][:id].inspect}")
    another_student_id = student_nodes[0][:id].split('_')[1]
    Rails.logger.debug("*** another_student_id: #{another_student_id}")
    page.find("tr#student_#{another_student_id}", wait: 5)
    within("tr#student_#{another_student_id}") do
      page.should have_css("a[data-url='/students/#{another_student_id}/security.js']")
      find("a[data-url='/students/#{another_student_id}/security.js']").click
    end
    sleep 1
    page.should have_content("Student/Parent Security and Access")
    page.click_button('Close')
  end

  def can_change_graduate(student)
    within("tr#student_#{student.id}.deactivated") do
      page.should have_css("a[data-url='/students/#{student.id}/edit.js']")
      find("a[data-url='/students/#{student.id}/edit.js']").click
      sleep 1
    end
    page.find("form#edit_student_#{student.id}", wait: 5)
    page.should have_content("Edit Student")
    within("#modal_popup .modal-dialog .modal-content .modal-body") do
      within("form#edit_student_#{student.id}") do
        page.find('#student_first_name', wait: 5).set('CFn')
        page.find('#student_last_name', wait: 5).set('CLn')
        page.click_button('Save')
      end
    end
    sleep 1
    assert_equal("/students", current_path)
    page.find("tr#student_#{student.id}.deactivated", wait: 5)
    within("tr#student_#{student.id}.deactivated") do
      page.should have_content('CFn')
      page.should have_content('CLn')
    end
  end

  #deactivate and reactivate a student from the Students List
  def can_deactivate_student(student)
    visit students_path if current_path != "/students"
    #student's initial state should be active
    confirm_student_activation_status(student, true)
    #deactivate student
    page.should have_css("#student_#{student.id}")
    page.find("#student_#{student.id}").find('#remove-student').click
    wait_for_accept_alert
    #student's state should be deactivated
    confirm_student_activation_status(student, false)
    #reactivate student
    page.find("#student_#{student.id} #restore-student").click
    wait_for_accept_alert
    confirm_student_activation_status(student, true)
  end

  def confirm_student_activation_status(student, active)
      #make sure that the student's status is correct
      #in the database
      student.reload
      assert_equal(active, student[:active])
      #make sure deactivated students are displayed with strikethrough text
      #and active students are displayed without strikethrough text
      page.should have_css("tr#student_#{student.id}#{active ? '.active' : '.deactivated'}")
  end

end
