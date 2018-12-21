# attendance_entry_spec.rb
require 'spec_helper'


describe "Attendance Entry", js:true do
  describe "US System", js:true do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: true
      create_and_load_us_model_school

      @school1 = FactoryBot.create :school_current_year, :us
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline
      load_test_section(@section1_1, @teacher1)

      @student_fname1 = FactoryBot.create :student, school: @school1, first_name: 'First', last_name: 'Shows First'
      @enrollment1_1_f = FactoryBot.create :enrollment, section: @section1_1, student: @student_fname1

      @teacher2 = FactoryBot.create :teacher, school: @school1

      @subject2 = FactoryBot.create :subject, subject_manager: @teacher1
      @section2_1 = FactoryBot.create :section, subject: @subject2
      @section2_2 = FactoryBot.create :section, subject: @subject2
      @discipline2 = @subject2.discipline

      @teaching_assignment2_1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section2_1
      @teaching_assignment2_2 = FactoryBot.create :teaching_assignment, teacher: @teacher2, section: @section2_2

      @enrollment2_1_2 = FactoryBot.create :enrollment, section: @section2_1, student: @student2
      @enrollment2_1_3 = FactoryBot.create :enrollment, section: @section2_1, student: @student3
      @enrollment2_2_4 = FactoryBot.create :enrollment, section: @section2_2, student: @student4
      @enrollment2_2_5 = FactoryBot.create :enrollment, section: @section2_2, student: @student5

      @at_tardy = FactoryBot.create :attendance_type, description: "Tardy", school: @school1
      @at_absent = FactoryBot.create :attendance_type, description: "Absent", school: @school1
      @at_deact = FactoryBot.create :attendance_type, description: "Deactivated", school: @school1, active: false
      @attendance_types = [@at_tardy, @at_absent, @at_deact]

      @excuse1 = FactoryBot.create :excuse, school: @school1, code: 'EX', description: 'Excused'
      @excuse2 = FactoryBot.create :excuse, school: @school1, code: 'DOC', description: "Doctor's note"
      @excuse3 = FactoryBot.create :excuse, school: @school1, code: 'TRIP', description: "Field Trip"
      @excuses = [@excuse1, @excuse2, @excuse3]


      # @school2
      @school2 = FactoryBot.create :school, :us
      @teacher2_1 = FactoryBot.create :teacher, school: @school2
      @subject2_1 = FactoryBot.create :subject, school: @school2, subject_manager: @teacher2_1
      @section2_1_1 = FactoryBot.create :section, subject: @subject2_1

      @at_tardy2 = FactoryBot.create :attendance_type, description: "Tardy2", school: @school2
      @excuse_sch2 = FactoryBot.create :excuse, school: @school2, code: 'OOS', description: "Out of school"


      # @student attendance
      # in two subjects on multiple days
      @attendance1 = FactoryBot.create :attendance,
        section: @section1_1,
        student: @student_fname1,
        attendance_type: @at_deact,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,1)
      @attendance2 = FactoryBot.create :attendance,
        section: @section1_1,
        student: @student_fname1,
        attendance_type: @at_absent,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,2)
      @attendance3 = FactoryBot.create :attendance,
        section: @section1_1,
        student: @student_fname1,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,4)

      @attendance4 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student_fname1,
        attendance_type: @at_deact,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,1)
      @attendance5 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student_fname1,
        attendance_type: @at_absent,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,2)
      @attendance6 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student_fname1,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,4)

      # other students
      # two sections of subject2 across two days
      @attendance7 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student3,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,1)
      @attendance8 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student2,
        attendance_type: @at_absent,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,2)
      @attendance9 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student3,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,2)

      # students not in @teacher1 classes on 9/5
      @attendance10 = FactoryBot.create :attendance,
        section: @section2_2,
        student: @student4,
        attendance_type: @at_absent,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,5)
      @attendance11 = FactoryBot.create :attendance,
        section: @section2_2,
        student: @student5,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,5)

    end

    describe "as teacher" do
      before do
        sign_in(@teacher1)
        @err_page = "/teachers/#{@teacher1.id}"
      end
      it { section_attendance_entry_is_valid }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
        @err_page = "/school_administrators/#{@school_administrator.id}"
      end
      it { section_attendance_entry_is_valid }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
        @err_page = "/researchers/#{@researcher.id}"
      end
      it { cannot_see_section_attendance_entry }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
        @err_page = "/system_administrators/#{@system_administrator.id}"
      end
      it { section_attendance_entry_is_valid }
    end

    describe "as student" do
      before do
        sign_in(@student)
        @err_page = "/students/#{@student.id}"
      end
      it { has_no_attendance }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
        @err_page = "/parents/#{@student.parent.id}"
      end
      it { has_no_attendance }
    end
  end

  describe "Egypt System", js:true do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: false
      create_and_load_arabic_model_school

      @school1 = FactoryBot.create :school_current_year, :arabic
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline
      load_test_section(@section1_1, @teacher1)

      @student_fname1 = FactoryBot.create :student, school: @school1, first_name: 'First', last_name: 'Shows First'
      @enrollment1_1_f = FactoryBot.create :enrollment, section: @section1_1, student: @student_fname1

      @teacher2 = FactoryBot.create :teacher, school: @school1

      @subject2 = FactoryBot.create :subject, subject_manager: @teacher1
      @section2_1 = FactoryBot.create :section, subject: @subject2
      @section2_2 = FactoryBot.create :section, subject: @subject2
      @discipline2 = @subject2.discipline

      @teaching_assignment2_1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section2_1
      @teaching_assignment2_2 = FactoryBot.create :teaching_assignment, teacher: @teacher2, section: @section2_2

      @enrollment2_1_2 = FactoryBot.create :enrollment, section: @section2_1, student: @student2
      @enrollment2_1_3 = FactoryBot.create :enrollment, section: @section2_1, student: @student3
      @enrollment2_2_4 = FactoryBot.create :enrollment, section: @section2_2, student: @student4
      @enrollment2_2_5 = FactoryBot.create :enrollment, section: @section2_2, student: @student5

      @at_tardy = FactoryBot.create :attendance_type, description: "Tardy", school: @school1
      @at_absent = FactoryBot.create :attendance_type, description: "Absent", school: @school1
      @at_deact = FactoryBot.create :attendance_type, description: "Deactivated", school: @school1, active: false
      @attendance_types = [@at_tardy, @at_absent, @at_deact]

      @excuse1 = FactoryBot.create :excuse, school: @school1, code: 'EX', description: 'Excused'
      @excuse2 = FactoryBot.create :excuse, school: @school1, code: 'DOC', description: "Doctor's note"
      @excuse3 = FactoryBot.create :excuse, school: @school1, code: 'TRIP', description: "Field Trip"
      @excuses = [@excuse1, @excuse2, @excuse3]


      # @school2
      @school2 = FactoryBot.create :school, :arabic
      @teacher2_1 = FactoryBot.create :teacher, school: @school2
      @subject2_1 = FactoryBot.create :subject, school: @school2, subject_manager: @teacher2_1
      @section2_1_1 = FactoryBot.create :section, subject: @subject2_1

      @at_tardy2 = FactoryBot.create :attendance_type, description: "Tardy2", school: @school2
      @excuse_sch2 = FactoryBot.create :excuse, school: @school2, code: 'OOS', description: "Out of school"


      # @student attendance
      # in two subjects on multiple days
      @attendance1 = FactoryBot.create :attendance,
        section: @section1_1,
        student: @student_fname1,
        attendance_type: @at_deact,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,1)
      @attendance2 = FactoryBot.create :attendance,
        section: @section1_1,
        student: @student_fname1,
        attendance_type: @at_absent,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,2)
      @attendance3 = FactoryBot.create :attendance,
        section: @section1_1,
        student: @student_fname1,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,4)

      @attendance4 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student_fname1,
        attendance_type: @at_deact,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,1)
      @attendance5 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student_fname1,
        attendance_type: @at_absent,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,2)
      @attendance6 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student_fname1,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,4)

      # other students
      # two sections of subject2 across two days
      @attendance7 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student3,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,1)
      @attendance8 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student2,
        attendance_type: @at_absent,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,2)
      @attendance9 = FactoryBot.create :attendance,
        section: @section2_1,
        student: @student3,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,2)

      # students not in @teacher1 classes on 9/5
      @attendance10 = FactoryBot.create :attendance,
        section: @section2_2,
        student: @student4,
        attendance_type: @at_absent,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,5)
      @attendance11 = FactoryBot.create :attendance,
        section: @section2_2,
        student: @student5,
        attendance_type: @at_tardy,
        excuse: @excuse1,
        attendance_date: Date.new(2015,9,5)

    end

    describe "as teacher" do
      before do
        sign_in(@teacher1)
        @err_page = "/teachers/#{@teacher1.id}"
      end
      it { section_attendance_entry_is_valid }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
        @err_page = "/school_administrators/#{@school_administrator.id}"
      end
      it { section_attendance_entry_is_valid }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
        @err_page = "/researchers/#{@researcher.id}"
      end
      it { cannot_see_section_attendance_entry }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
        @err_page = "/system_administrators/#{@system_administrator.id}"
      end
      it { section_attendance_entry_is_valid }
    end

    describe "as student" do
      before do
        sign_in(@student)
        @err_page = "/students/#{@student.id}"
      end
      it { has_no_attendance }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
        @err_page = "/parents/#{@student.parent.id}"
      end
      it { has_no_attendance }
    end
  end


  ##################################################
  # test methods

  def has_no_attendance
    # should not have toolkit item to enter attendance
    page.should_not have_css("#side-attend")
    # should fail when going to section page directly
    visit section_path(@section1_1.id)
    assert_equal(@err_page, current_path)
    # should fail when going to section attendance page directly
    visit section_attendance_attendance_path(@section1_1.id)
    assert_equal(@err_page, current_path)
    page.should_not have_content('Internal Server Error')
  end

  def cannot_see_section_attendance_entry
    # should not have a active toolkit item to enter attendance
    page.should have_css("#side-attend")
    # visit section to see if section attendance becomes active link in toolkit
    visit section_path(@section1_1.id)
    # need to tighten up security on this.  note they cannot see page, just have a link to it
    within("#side-attend") do
      page.should have_css("a.disabled")
    end
    # should not let unauthorized user see the section attendance page
    visit section_attendance_attendance_path(@section1_1.id)
    assert_equal(@err_page, current_path)
  end

  def section_attendance_entry_is_valid

    # should not have a active toolkit item to enter attendance
    # visit section to see if section attendance becomes active link
    visit section_path(@section1_1.id)

    within("#side-attend") do
      page.should_not have_css("a.disabled")
      find("a[href='/attendances/#{@section1_1.id}/section_attendance']").click
    end

    # page should show attendance for current date
    within("form .block-title") do
      page.should have_content("Section Attendance for #{Date.today.to_s}")
    end

    # change attendance date to 9/1
    page.should have_css("#attendance_date_field")
    find("#attendance_date_field").value.should == Date.today.to_s
    page.execute_script("$('#attendance_date_field').val('2015-09-01')")
    page.execute_script("$('#attendance_date_field').trigger('change')")
    within("form .block-title") do
      page.should have_content("Section Attendance for 2015-09-01")
    end

    # confirm only school1 attendance types are listed
    within("table#attendance_table tbody tr#attendance_#{@student_fname1.id} select#attendance_#{@student_fname1.id}_attendance_type_id") do
      page.should_not have_content('Tardy2')
    end
    within("table#attendance_table tbody tr#attendance_#{@student_fname1.id} select#attendance_#{@student_fname1.id}_excuse_id") do
      page.should_not have_content('Out of school')
    end
    # confirm students are listed in correct order, and values already loaded are displayed.
    within("table#attendance_table") do
      page.should have_content("First Shows First")
      page.should have_content("#{@student_fname1.full_name}")
      find("select#attendance_#{@student_fname1.id}_attendance_type_id").value.should == @at_deact.id.to_s
      find("select#attendance_#{@student_fname1.id}_excuse_id").value.should == @attendance1.excuse.id.to_s
      find("input#attendance_#{@student_fname1.id}_comment").value.should == @attendance1.comment
    end
    if (ServerConfig.first.try(:allow_subject_mgr)) != true
      # arabic school
      page.should have_css("table#attendance_table tbody tr:nth-of-type(1)[id='attendance_#{@student_fname1.id}']")
      within("table#attendance_table tbody tr:nth-of-type(2)") do
        page.should have_content("#{@student.full_name}")
        find("select#attendance_#{@student.id}_attendance_type_id").value.should == ""
        find("select#attendance_#{@student.id}_excuse_id").value.should ==  ""
        find("input#attendance_#{@student.id}_comment").value.should == ""
      end
      page.should have_css("table#attendance_table tbody tr:nth-of-type(2)[id='attendance_#{@student.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(3)[id='attendance_#{@student2.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(4)[id='attendance_#{@student3.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(5)[id='attendance_#{@student4.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(6)[id='attendance_#{@student5.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(7)[id='attendance_#{@student6.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(8)[id='attendance_#{@student_new.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(9)[id='attendance_#{@student_transferred.id}']")
    else
      # us school
      page.should have_css("table#attendance_table tbody tr:nth-of-type(8)[id='attendance_#{@student_fname1.id}']")
      within("table#attendance_table tbody tr:nth-of-type(1)") do
        page.should have_content("#{@student.full_name}")
        find("select#attendance_#{@student.id}_attendance_type_id").value.should == ""
        find("select#attendance_#{@student.id}_excuse_id").value.should ==  ""
        find("input#attendance_#{@student.id}_comment").value.should == ""
      end
      page.should have_css("table#attendance_table tbody tr:nth-of-type(1)[id='attendance_#{@student.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(2)[id='attendance_#{@student2.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(3)[id='attendance_#{@student3.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(4)[id='attendance_#{@student4.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(5)[id='attendance_#{@student5.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(6)[id='attendance_#{@student6.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(7)[id='attendance_#{@student_new.id}']")
      page.should have_css("table#attendance_table tbody tr:nth-of-type(9)[id='attendance_#{@student_transferred.id}']")
    end

    # navbar-nav-custom-content
    page.fill_in "attendance_#{@student_fname1.id}_comment", :with => 'Changed comment!'
    select('Tardy', from: "attendance_#{@student.id}_attendance_type_id")
    select('Field Trip', from: "attendance_#{@student.id}_excuse_id")
    page.should have_css("input#save_attendance", visible: true)
    find("input#save_attendance").click

    if (ServerConfig.first.try(:allow_subject_mgr)) != true
      # confirm updated values are displayed.
      within("table#attendance_table tbody tr:nth-of-type(1)") do
        find("input#attendance_#{@student_fname1.id}_comment").value.should == 'Changed comment!'
      end
    else
      within("table#attendance_table tbody tr:nth-of-type(8)") do
        find("input#attendance_#{@student_fname1.id}_comment").value.should == 'Changed comment!'
      end
    end
    if (ServerConfig.first.try(:allow_subject_mgr)) != true
      page.should have_css("table#attendance_table tbody tr:nth-of-type(1)[id='attendance_#{@student_fname1.id}']")
      within("table#attendance_table tbody tr:nth-of-type(2)") do
        page.should have_content("#{@student.full_name}")
        find("select#attendance_#{@student.id}_attendance_type_id").value.should == @at_tardy.id.to_s
        find("select#attendance_#{@student.id}_excuse_id").value.should ==  @excuse3.id.to_s
        find("input#attendance_#{@student.id}_comment").value.should == ""
      end
    else
      page.should have_css("table#attendance_table tbody tr:nth-of-type(8)[id='attendance_#{@student_fname1.id}']")
      within("table#attendance_table tbody tr:nth-of-type(1)") do
        page.should have_content("#{@student.full_name}")
        find("select#attendance_#{@student.id}_attendance_type_id").value.should == @at_tardy.id.to_s
        find("select#attendance_#{@student.id}_excuse_id").value.should ==  @excuse3.id.to_s
        find("input#attendance_#{@student.id}_comment").value.should == ""
      end
    end
  end  # section_attendance_entry_is_valid

end
