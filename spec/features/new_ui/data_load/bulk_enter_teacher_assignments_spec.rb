# bulk_enter_teacher_assignments_spec.rb

require 'rails_helper'

describe "Bulk Enter Teacher Assignments", js:true do

  describe "US System", js:true do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: true
      create_and_load_us_model_school

      # create school with Three sections in Year 1
      # two sections with unassigned teachers
      @school1 = FactoryBot.create :school_prior_year, :us
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @ta1_1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_1
      @section1_2 = FactoryBot.create :section, subject: @subject1
      @section1_3 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline

      # switch to year 2 for @school1
      @current_school_year = FactoryBot.create :current_school_year, school: @school1
      @school1.school_year_id = @current_school_year.id
      @school1.save

      # regular setup for Year 2

      @section2_1 = FactoryBot.create :section, subject: @subject1
      load_test_section(@section2_1, @teacher1)
      @section2_2 = FactoryBot.create :section, subject: @subject1
      @section2_3 = FactoryBot.create :section, subject: @subject1

    end

    describe "as teacher" do
      before do
        sign_in(@teacher1)
      end
      it { no_bulk_enter_teacher_assignments }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
      end
      it { valid_bulk_enter_teacher_assignments }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
      end
      it { no_bulk_enter_teacher_assignments }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
      end
      it { valid_bulk_enter_teacher_assignments }
    end

    describe "as student" do
      before do
        sign_in(@student)
      end
      it { no_bulk_enter_teacher_assignments }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
      end
      it { no_bulk_enter_teacher_assignments }
    end
  end

  describe "Egypt System", js:true do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: false
      create_and_load_arabic_model_school

      # create school with Three sections in Year 1
      # two sections with unassigned teachers
      @school1 = FactoryBot.create :school_prior_year, :arabic
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @ta1_1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_1
      @section1_2 = FactoryBot.create :section, subject: @subject1
      @section1_3 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline

      # switch to year 2 for @school1
      @current_school_year = FactoryBot.create :current_school_year, school: @school1
      @school1.school_year_id = @current_school_year.id
      @school1.save

      # regular setup for Year 2

      @section2_1 = FactoryBot.create :section, subject: @subject1
      load_test_section(@section2_1, @teacher1)
      @section2_2 = FactoryBot.create :section, subject: @subject1
      @section2_3 = FactoryBot.create :section, subject: @subject1

    end

    describe "as teacher" do
      before do
        sign_in(@teacher1)
      end
      it { no_bulk_enter_teacher_assignments }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
      end
      it { valid_bulk_enter_teacher_assignments }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
      end
      it { no_bulk_enter_teacher_assignments }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
      end
      it { valid_bulk_enter_teacher_assignments }
    end

    describe "as student" do
      before do
        sign_in(@student)
      end
      it { no_bulk_enter_teacher_assignments }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
      end
      it { no_bulk_enter_teacher_assignments }
    end
  end
  ##################################################
  # test methods

  def no_bulk_enter_teacher_assignments
    visit enter_bulk_teaching_assignments_path
    assert_not_equal("/teaching_assignments/enter_bulk", current_path)
  end

  def valid_bulk_enter_teacher_assignments

    # confirm on Year 2
    visit schools_path()
    within("tr#school-#{@school1.id} td.school-year") do
      page.should have_content(get_std_current_school_year_name)
    end

    visit enter_bulk_teaching_assignments_path

    assert_equal("/teaching_assignments/enter_bulk", current_path)

    within("form[action='/teaching_assignments/update_bulk']") do
      page.should have_css("tr#sect_#{@section2_2.id}")
      page.should have_css("tr#sect_#{@section2_3.id}")
      page.should_not have_css("tr#sect_#{@section1_2.id}")
      page.should_not have_css("tr#sect_#{@section1_3.id}")
    end

  end

end
