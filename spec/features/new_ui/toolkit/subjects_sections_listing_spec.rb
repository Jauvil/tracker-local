# subject_sections_listing_spec.rb
require 'spec_helper'


describe "Subjects Sections Listing", js:true do
  describe "US System" do
    before (:each) do

      # two subjects in @school1
      # @section1_1 = FactoryGirl.create :section
      # @subject1 = @section1_1.subject
      # @school1 = @section1_1.school
      @school1 = FactoryGirl.create :school, :us
      @subject1 = FactoryGirl.create :subject, school: @school1
      @section1_1 = FactoryGirl.create :section, subject: @subject1
      @teacher1 = @subject1.subject_manager
      @discipline = @subject1.discipline


      load_test_section(@section1_1, @teacher1)

      @section1_2 = FactoryGirl.create :section, subject: @subject1
      @ta1 = FactoryGirl.create :teaching_assignment, teacher: @teacher1, section: @section1_2
      @section1_3 = FactoryGirl.create :section, subject: @subject1
      @ta2 = FactoryGirl.create :teaching_assignment, teacher: @teacher1, section: @section1_3

      @subject2 = FactoryGirl.create :subject, subject_manager: @teacher1
      @section2_1 = FactoryGirl.create :section, subject: @subject2
      @section2_2 = FactoryGirl.create :section, subject: @subject2
      @section2_3 = FactoryGirl.create :section, subject: @subject2
      @discipline2 = @subject2.discipline

      # another subject in @school2
      @school2 = FactoryGirl.create :school, :us
      @subject3 = FactoryGirl.create :subject, school: @school2
      @section3_1 = FactoryGirl.create :section, subject: @subject3
      @section3_2 = FactoryGirl.create :section, subject: @subject3
      @section3_3 = FactoryGirl.create :section, subject: @subject3
      @teacher2 = @subject1.subject_manager
      #@section3_1 = FactoryGirl.create :section
      #@subject3 = @section3_1.subject
      #@school2 = @section3_1.school

    end

    describe "as assigned teacher" do
      before do
        sign_in(@teacher1)
        #if @teacher1 isn't Subject Admin or manage subject admin.. they can't update subjects.
      end
      it { has_valid_subjects_listing(@teacher1, false, true) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryGirl.create :school_administrator, school: @school1
        sign_in(@school_administrator)
      end
      it { has_valid_subjects_listing(@school_administrator, false, true) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryGirl.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
      end
      it { has_valid_subjects_listing(@researcher, false, false) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryGirl.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
      end
      it { has_valid_subjects_listing(@system_administrator, true, true) }
    end

    describe "as student" do
      before do
        sign_in(@student)
      end
      it { has_no_subjects_listing }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
      end
      it { has_no_subjects_listing }
    end
  end

  describe "Egypt System" do
    before (:each) do

      # two subjects in @school1
      # @section1_1 = FactoryGirl.create :section
      # @subject1 = @section1_1.subject
      # @school1 = @section1_1.school
      @school1 = FactoryGirl.create :school, :arabic
      @subject1 = FactoryGirl.create :subject, school: @school1
      @section1_1 = FactoryGirl.create :section, subject: @subject1
      @teacher1 = @subject1.subject_manager
      @discipline = @subject1.discipline


      load_test_section(@section1_1, @teacher1)

      @section1_2 = FactoryGirl.create :section, subject: @subject1
      @ta1 = FactoryGirl.create :teaching_assignment, teacher: @teacher1, section: @section1_2
      @section1_3 = FactoryGirl.create :section, subject: @subject1
      @ta2 = FactoryGirl.create :teaching_assignment, teacher: @teacher1, section: @section1_3

      @subject2 = FactoryGirl.create :subject, school: @school1
      @section2_1 = FactoryGirl.create :section, subject: @subject2
      @section2_2 = FactoryGirl.create :section, subject: @subject2
      @section2_3 = FactoryGirl.create :section, subject: @subject2
      @discipline2 = @subject2.discipline

      # another subject in @school2
      @school2 = FactoryGirl.create :school, :arabic
      @subject3 = FactoryGirl.create :subject, school: @school2
      @section3_1 = FactoryGirl.create :section, subject: @subject3
      @section3_2 = FactoryGirl.create :section, subject: @subject3
      @section3_3 = FactoryGirl.create :section, subject: @subject3
      @teacher2 = @subject1.subject_manager
      #@section3_1 = FactoryGirl.create :section
      #@subject3 = @section3_1.subject
      #@school2 = @section3_1.school

    end

    describe "as assigned teacher" do
      before do
        sign_in(@teacher1)
        #if @teacher1 isn't Subject Admin or manage subject admin.. they can't update subjects.
      end
      it { has_valid_subjects_listing(@teacher1, false, true) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryGirl.create :school_administrator, school: @school1
        sign_in(@school_administrator)
      end
      it { has_valid_subjects_listing(@school_administrator, false, true) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryGirl.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
      end
      it { has_valid_subjects_listing(@researcher, false, false) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryGirl.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
      end
      it { has_valid_subjects_listing(@system_administrator, true, true) }
    end

    describe "as student" do
      before do
        sign_in(@student)
      end
      it { has_no_subjects_listing }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
      end
      it { has_no_subjects_listing }
    end
  end

  ##################################################
  # test methods

  def has_no_subjects_listing
    visit subjects_path()
    assert_not_equal("/subjects", current_path)
    Rails.logger.debug("+++ end has_no_subjects_listing")
  end

  def has_valid_subjects_listing(this_user, can_create_subject, can_create_section)
    Rails.logger.debug("+++ school1.id #{@school1.id}")
    Rails.logger.debug("+++ check subject1 created #{@subject1}")
    Rails.logger.debug("+++ start has_valid_subjects")
    visit subjects_path

    # ensure users can edit the appropriate subject outcomes, all else can view.
    if(this_user.id == (@subject1.subject_manager_id && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER)) ||
      # ToDO create user.has_role?
      (this_user.has_role?('school_administrator') && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER)) ||
      (this_user.has_role?('system_administrator') && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER))
      # School administrators must be given subject administrator to see this
      # this_user.id == @subject1.subject_manager_id ||
      # this_user.has_permission?('subject_admin')
      # this_user.has_permission?('manage_subject_admin')
    )
      save_and_open_page
      sleep 20
      page.should have_css("a[href='/subjects/#{@subject1.id}/edit_subject_outcomes']")
    else
      save_and_open_page
      page.should_not have_css("a[href='/subjects/#{@subject1.id}/edit_subject_outcomes']")
      page.should have_css("a[data-url='/subjects/#{@subject1.id}/view_subject_outcomes']")
    end

    if(this_user.id == (@subject2.subject_manager_id && ServerConfig.first.try(:allow_subject_mgr) && @school2.has_flag?(School::SUBJECT_MANAGER)) ||
      (this_user.has_role?('school_administrator') && ServerConfig.first.try(:allow_subject_mgr) && @school2.has_flag?(School::SUBJECT_MANAGER)) ||
      (this_user.has_role?('system_administrator') && ServerConfig.first.try(:allow_subject_mgr) && @school2.has_flag?(School::SUBJECT_MANAGER))
      # School administrators must be given subject administrator to see this
      # (this_user.role_symbols.include?('school_administrator'.to_sym) && this_user.school_id == @school1.id)
    )
      page.should have_css("a[href='/subjects/#{@subject2.id}/edit_subject_outcomes']")
    else
      page.should have_css("a[data-url='/subjects/#{@subject2.id}/view_subject_outcomes']")
      page.should_not have_css("a[href='/subjects/#{@subject2.id}/edit_subject_outcomes']")
    end
    # note: subject3 is in a different school, so would not be shown
    page.should_not have_css("a[href='/subjects/#{@subject3.id}/edit_subject_outcomes']")
    page.should_not have_css("a[data-url='/subjects/#{@subject3.id}/view_subject_outcomes']")

    # ensure users can view section outcomes
    # note: future enhance UI to allow those who can, to edit instead of view
    # if(this_user.role_symbols.include?('system_administrator'.to_sym) ||
    #   this_user.role_symbols.include?('researcher'.to_sym) ||
    #   (this_user.role_symbols.include?('school_administrator'.to_sym) && this_user.school_id == @school1.id) ||
    #   (this_user.role_symbols.include?('counselor'.to_sym) && this_user.school_id == @school1.id) ||
    #   (this_user.role_symbols.include?('teacher'.to_sym) && this_user.school_id == @school1.id)
    #   # (this_user.role_symbols.include?('teacher'.to_sym) &&
    #   #   ( this_user.id == @subject1.subject_manager_id || this_user.has_permission?('subject_admin')  || @ta1.teacher_id == this_user.id
    #   #   )
    #   # )
    # )
    #   page.should have_css("a[data-url='/sections/#{@section1_1.id}/section_outcomes.js']")
    #   page.should have_css("a[data-url='/sections/#{@section1_2.id}/section_outcomes.js']")
    #   page.should have_css("a[data-url='/sections/#{@section1_3.id}/section_outcomes.js']")
    # else
    #   page.should_not have_css("a[data-url='/sections/#{@section1_1.id}/section_outcomes.js']")
    #   page.should_not have_css("a[data-url='/sections/#{@section1_2.id}/section_outcomes.js']")
    #   page.should_not have_css("a[data-url='/sections/#{@section1_3.id}/section_outcomes.js']")
    # end
    # all users should be able to view section outcomes (since they can see subject outcomes)
    page.should have_css("a[data-url='/sections/#{@section1_1.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section1_2.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section1_3.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section2_1.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section2_2.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section2_3.id}/section_outcomes.js']")

    # all users should be able to see the subject dashboards, both as the link on the name and the icon
    within("tbody#subj_header_#{@subject1.id}") do
      page.should have_css("a[href='/subjects/#{@subject1.id}'] strong", text: "#{@subject1.discipline.name} : #{@subject1.name}")
      page.should have_css("a[href='/subjects/#{@subject1.id}'] i.fa-dashboard")
    end


    within("#page-content") do
      page.should have_content('Subjects / Sections Listing')
      page.should_not have_content("#{@subject3.discipline.name} : #{@subject3.name}")
      within("tbody#subj_header_#{@subject1.id}") do
        page.should have_content("#{@subject1.discipline.name} : #{@subject1.name}")
        page.should_not have_content("#{@subject2.discipline.name} : #{@subject2.name}")
      end
      within("tbody#subj_body_#{@subject1.id}") do
        within("#sect_#{@section1_1.id}") do
          page.should have_content("#{@teacher1.full_name}")
          page.should have_content("#{@section1_1.line_number}")
          page.should have_content("#{@section1_1.active_students.count}")
        end
        within("#sect_#{@section1_2.id}") do
          page.should have_content("#{@teacher1.full_name}")
          page.should have_content("#{@section1_2.line_number}")
          page.should have_content("#{@section1_2.active_students.count}")
        end
        within("#sect_#{@section1_3.id}") do
          page.should have_content("#{@teacher1.full_name}")
          page.should have_content("#{@section1_3.line_number}")
          page.should have_content("#{@section1_3.active_students.count}")
        end
        page.should_not have_css("#sect_#{@section2_1.id}")
        page.should_not have_css("#sect_#{@section2_2.id}")
        page.should_not have_css("#sect_#{@section2_3.id}")
      end

      within("tbody#subj_header_#{@subject2.id}") do
        page.should_not have_content("#{@subject1.discipline.name} : #{@subject1.name}")
        page.should have_content("#{@subject2.discipline.name} : #{@subject2.name}")
      end
      within("tbody#subj_body_#{@subject2.id}") do
        within("#sect_#{@section2_1.id}") do
          page.should_not have_content("#{@teacher1.full_name}")
          page.should have_content("#{@section2_1.line_number}")
          page.should have_content("#{@section2_1.active_students.count}")
        end
        within("#sect_#{@section2_2.id}") do
          page.should_not have_content("#{@teacher1.full_name}")
          page.should have_content("#{@section2_2.line_number}")
          page.should have_content("#{@section2_2.active_students.count}")
        end
        within("#sect_#{@section2_3.id}") do
          page.should_not have_content("#{@teacher1.full_name}")
          page.should have_content("#{@section2_3.line_number}")
          page.should have_content("#{@section2_3.active_students.count}")
        end
        page.should_not have_css("#sect_#{@section1_1.id}")
        page.should_not have_css("#sect_#{@section1_2.id}")
        page.should_not have_css("#sect_#{@section1_3.id}")
      end

      # click on right arrow should minimize subject
      page.should_not have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
      page.should_not have_css("tbody#subj_header_#{@subject2.id}.show-tbody-body")
      find("a#subj_header_#{@subject1.id}_a").click
      page.should have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
      # click on down arrow should maximize subject
      find("a#subj_header_#{@subject1.id}_a").click
      page.should_not have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")


      # todo - click on down arrow at top of page should maximize all subjects
      find("a#expand-all-tbodies").click
      page.should have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
      page.should have_css("tbody#subj_header_#{@subject2.id}.show-tbody-body")

      # todo - click on right arrow at top of page should minimize all subjects
      find("a#collapse-all-tbodies").click
      page.should_not have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
      page.should_not have_css("tbody#subj_header_#{@subject2.id}.show-tbody-body")

    end # within("#page-content") do

    if (can_create_subject)
      # click on add subject should show add subject popup
      page.should have_css("a[data-url='/subjects/new.js']")
      find("a[data-url='/subjects/new.js']").click
      Rails.logger.debug("+++ create subject popup")

      within('#modal-body') do
        within('h3') do
          page.should have_content('Create Subject')
        end
        within('#new_subject') do
          sleep 10
          select('Discipline 1', from: 'subject-discipline-id')

          page.fill_in 'subject[name]', :with => 'Newsubj'

          page.click_button('Save')
        end
        Rails.logger.debug("+++ popup closed")
      end

      Rails.logger.debug("+++ back to Subjects list page")
      Rails.logger.debug("+++ check if NEW subject exist")
      page.should have_content("Newsubj")

      Rails.logger.debug("+++ start editing subject")
      # click on edit subject should show edit subject popup
      page.should have_css("a[href='/subjects/#{@subject1.id}/edit']")
      find("a[href='/subjects/#{@subject2.id}/edit']").click
      Rails.logger.debug("+++ edit subject popup")
      within('#modal-body') do
        Rails.logger.debug("+++ Edit Subject popup")
        within('h3') do
          page.should have_content("Edit Subject - #{@subject2.name}")
        end
        within('.edit_subject') do
          #find the properties for NAME and DISCIPLINE to update subject
          sleep 10
          select('Discipline 2', from: 'subject-discipline-id')
          page.fill_in 'subject-name', :with => 'Subname'
          page.click_button('Save')
          Rails.logger.debug("+++ update & save new subject")
          Rails.logger.debug("+++ done with popup")
        end
      end
      Rails.logger.debug("+++ check for EDITED subject")
      page.should have_content("Discipline 2")
      page.should have_content("Subname")
    end


    if (can_create_section)
      Rails.logger.debug("+++ can_create_section")


       find("a#collapse-all-tbodies").click
       page.should_not have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
       page.should_not have_css("tbody#subj_header_#{@subject2.id}.show-tbody-body")

       find("a#subj_header_#{@subject1.id}_a").click
       Rails.logger.debug("+++ found subject?")

      # click on edit section should show edit section popup
       page.should have_css("a[data-url='/sections/#{@section1_2.id}/edit.js']")
       find("a[data-url='/sections/#{@section1_2.id}/edit.js']").click

      within("tr#sect_#{@section1_2.id}") do
        page.should have_content(@section1_2.line_number)
      end

       within('#modal-body') do
      #   Rails.logger.debug("+++ in popup")
         within('h2') do
      #     # if(can_create_subject)
      #     #   page.should have_content("Edit Section: Changed Subject Name - #{@section1_2.line_number}")
      #     # else
             page.should have_content("Edit Section: #{@section1_2.name} - #{@section1_2.line_number}")
      #     # end
         end
        Rails.logger.debug("+++ should have line number name")
        within('#section_line_number') do
          page.should_not have_content(@section1_2.subject.name)
        end
        Rails.logger.debug("+++ should have line number")
        page.should have_selector("#section_line_number", value: "#{@section1_2.line_number}")
        page.fill_in 'section[line_number]', :with => 'Changed'
        # within('#section_message') do
        #   Rails.logger.debug("+++ section message: #{@section1_2.message}")
        #   page.should have_content(@section1_2.message)
        # end
        page.should have_selector("#section_school_year_id", value: "#{@section1_2.school_year.name}")

        Rails.logger.debug("+++ click save")
        page.click_button('Save')
        Rails.logger.debug("+++ done with popup")
      end
      Rails.logger.debug("+++ out of popup")
      within("tr#sect_#{@section1_2.id}") do
        page.should have_content("Changed")
      end


    end
    Rails.logger.debug("+++ end has_valid_subjects_listing")
  end # def has_valid_subjects_listing
end
