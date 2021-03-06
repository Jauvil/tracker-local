# subject_sections_listing_spec.rb
require 'rails_helper'


describe "Subjects Sections Listing", js:true do
  describe "US System" do
    before (:each) do
       @server_config = FactoryBot.create :server_config, allow_subject_mgr: true
      # two subjects in @school1
      # @section1_1 = FactoryBot.create :section
      # @subject1 = @section1_1.subject
      # @school1 = @section1_1.school
      @school1 = FactoryBot.create :school, :us
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @teacher3 = FactoryBot.create :teacher, school: @school1
      @discipline = @subject1.discipline
      @section1_1 = FactoryBot.create :section, subject: @subject1

      load_test_section(@section1_1, @teacher1)

      @section1_2 = FactoryBot.create :section, subject: @subject1
      @ta1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_2
      @section1_3 = FactoryBot.create :section, subject: @subject1
      @ta2 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_3

      @subject2 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section2_1 = FactoryBot.create :section, subject: @subject2
      @section2_2 = FactoryBot.create :section, subject: @subject2
      @section2_3 = FactoryBot.create :section, subject: @subject2
      @discipline2 = @subject2.discipline

      # another subject in @school2
      @school2 = FactoryBot.create :school, :us
      @subject3 = FactoryBot.create :subject, school: @school2
      @section3_1 = FactoryBot.create :section, subject: @subject3
      @section3_2 = FactoryBot.create :section, subject: @subject3
      @section3_3 = FactoryBot.create :section, subject: @subject3
      @teacher2 = @subject3.subject_manager
      @teacher4 = FactoryBot.create :teacher, school: @school2
      @discipline3 = @subject3.discipline
      #@section3_1 = FactoryBot.create :section
      #@subject3 = @section3_1.subject
      #@school2 = @section3_1.school

    end

    describe "as subject manager teacher" do
      before do
        sign_in(@teacher1)
        #if @teacher isn't Subject manager then they can't edit LO'S.
      end
      it { has_valid_subjects_listing(@teacher1, false, false) }
    end

    describe "as Regular teacher" do
      before do
        sign_in(@teacher3)
        #if @teacher isn't Subject manager then they can't edit LO'S.
      end
      it { has_valid_subjects_listing(@teacher3, false, false) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
      end
      it { has_valid_subjects_listing(@school_administrator, false, true) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
      end
      it { has_valid_subjects_listing(@researcher, false, false) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
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

  #Egypt System should fail the test:
  # -Subjects Sections Listing Egypt System as system administrator should have visible css "select#subject_subject_manager_id.select-select2"
  describe "Egypt System" do
    before (:each) do
       @server_config = FactoryBot.create :server_config, allow_subject_mgr: false
      # two subjects in @school1
      # @section1_1 = FactoryBot.create :section
      # @subject1 = @section1_1.subject
      # @school1 = @section1_1.school
      @school1 = FactoryBot.create :school, :arabic
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @teacher3 = FactoryBot.create :teacher, school: @school1
      @discipline = @subject1.discipline
      @section1_1 = FactoryBot.create :section, subject: @subject1


      load_test_section(@section1_1, @teacher1)

      @section1_2 = FactoryBot.create :section, subject: @subject1
      @ta1 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_2
      @section1_3 = FactoryBot.create :section, subject: @subject1
      @ta2 = FactoryBot.create :teaching_assignment, teacher: @teacher1, section: @section1_3

      @subject2 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section2_1 = FactoryBot.create :section, subject: @subject2
      @section2_2 = FactoryBot.create :section, subject: @subject2
      @section2_3 = FactoryBot.create :section, subject: @subject2
      @discipline2 = @subject2.discipline

      # another subject in @school2
      @school2 = FactoryBot.create :school, :arabic
      @subject3 = FactoryBot.create :subject, school: @school2
      @section3_1 = FactoryBot.create :section, subject: @subject3
      @section3_2 = FactoryBot.create :section, subject: @subject3
      @section3_3 = FactoryBot.create :section, subject: @subject3
      @teacher2 = @subject1.subject_manager
      @teacher4 = FactoryBot.create :teacher, school: @school2
      #@section3_1 = FactoryBot.create :section
      #@subject3 = @section3_1.subject
      #@school2 = @section3_1.school

    end

    describe "as Subject Manager teacher" do
      before do
        sign_in(@teacher1)
        #if @teacher isn't Subject manager then they can't edit LO'S.
      end
      it { has_valid_subjects_listing(@teacher1, false, false) }
    end

    describe "as Regular teacher" do
      before do
        sign_in(@teacher3)
        #if @teacher isn't Subject manager then they can't edit LO'S.
      end
      it { has_valid_subjects_listing(@teacher3, false, false) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
      end
      it { has_valid_subjects_listing(@school_administrator, false, true) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
      end
      it { has_valid_subjects_listing(@researcher, false, false) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
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
    visit subjects_path
    Rails.logger.debug("+++ test enter_bulk button")

    within(".header-block") do
      page.should have_css("a[id='collapse-all-tbodies'][href='javascript:void(0)'] i.fa-caret-right")
      page.should have_css("a[id='expand-all-tbodies'][href='javascript:void(0)'] i.fa-caret-down")
      page.should have_css("a[id='filter-button'][href='javascript:void(0)'] i.fa-filter")
      page.should have_css("a[id='print-button'][href='javascript:void(0)'] i.fa-print")
      page.should have_css("a[id='download-button'][href='javascript:void(0)'] i.fa-download")
      if :researcher || :teacher
        page.should_not have_css("a[href='enrollments/enter_bulk']")
        page.should_not have_css("a[href='sections/enter_bulk']")
        page.should_not have_css("a[href='teaching_assignments/enter_bulk']")
        page.should_not have_css("a[href='enrollments/enter_bulk']")
        page.should_not have_css("a.dim[id='rollover-#{@school1.id}'][href='javascript:void(0)'] i.fa-forward")
      else
        page.should have_css("a[data-url='subjects/new.js']")
        page.should have_css("a[href='sections/enter_bulk']")
        page.should have_css("a[href='teaching_assignments/enter_bulk']")
        page.should have_css("a[href='enrollments/enter_bulk']")
        page.should have_css("a.dim[id='rollover-#{@school1.id}'][href='javascript:void(0)'] i.fa-forward")
      end
    end

    sleep 1
    # ensure users can edit the appropriate subject outcomes, all else can view.
    if((this_user.id == @subject1.subject_manager_id && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER)) ||
      (this_user.school_administrator? && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER)) ||
      (this_user.system_administrator? && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER))
      # School administrators must be given subject administrator to see this
      # this_user.id == @subject1.subject_manager_id ||
      # this_user.has_permission?('subject_admin')
      # this_user.has_permission?('manage_subject_admin')
      )
      Rails.logger.debug("+++ try to see VIEW SUBJECT OUTCOMES")
      page.should have_css("a[href='/subjects/#{@subject1.id}/edit_subject_outcomes']")
    else
      page.should have_css("a[data-url='/subjects/#{@subject1.id}/view_subject_outcomes']")
    end

    Rails.logger.debug("+++ try to SUBJECT 2 OUTCOMES")
    if((this_user.id == @subject2.subject_manager_id && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER)) ||
      (this_user.school_administrator? && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER)) ||
      (this_user.system_administrator? && ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER))
      # School administrators must be given subject administrator to see this
      # (this_user.role_symbols.include?('school_administrator'.to_sym) && this_user.school_id == @school1.id)
    )
      Rails.logger.debug("+++ try to see subj 2 VIEW SUBJECT OUTCOMES")
      page.should have_css("a[href='/subjects/#{@subject2.id}/edit_subject_outcomes']")
    else
      page.should have_css("a[data-url='/subjects/#{@subject2.id}/view_subject_outcomes']")
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

    # open up sections for @subject1
    page.should_not have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
    # click on down arrow should maximize subject
    page.find("#subj_header_#{@subject1.id}_a", wait: 5).click
    page.should have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
    page.should have_css("a[data-url='/sections/#{@section1_1.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section1_2.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section1_3.id}/section_outcomes.js']")

    # open up sections for @subject2
    page.should_not have_css("tbody#subj_header_#{@subject2.id}.show-tbody-body")
    page.find("#subj_header_#{@subject2.id}_a", wait: 5).click
    page.should have_css("tbody#subj_header_#{@subject2.id}.show-tbody-body")
    page.should have_css("a[data-url='/sections/#{@section2_1.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section2_2.id}/section_outcomes.js']")
    page.should have_css("a[data-url='/sections/#{@section2_3.id}/section_outcomes.js']")

    # all users should be able to see the subject dashboards, both as the link on the name and the icon
    within("tbody#subj_header_#{@subject1.id}") do
      page.should have_css("a[href='/subjects/#{@subject1.id}'] strong", text: "#{@subject1.discipline.name} : #{@subject1.name}")
      page.should have_css("a[href='/subjects/#{@subject1.id}'] i.fa-dashboard")
    end

    Rails.logger.debug("+++ page-content")
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
      # subjects are currently maximized.
      # click on down arrow should minimize subject
      page.should have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
      find("a#subj_header_#{@subject1.id}_a").click
      page.should_not have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
      # click on right arrow should minimize subject
      find("a#subj_header_#{@subject1.id}_a").click
      page.should have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")


      # Click on down arrow at top of page should maximize all subjects
      find("a#expand-all-tbodies").click
      page.should have_css("tbody#subj_header_#{@subject1.id}.show-tbody-body")
      page.should have_css("tbody#subj_header_#{@subject2.id}.show-tbody-body")

      # Click on right arrow at top of page should minimize all subjects
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
        #Egypt school should fail check for 'select#subject_subject_manager_id.select-select2'
        if (ServerConfig.first.try(:allow_subject_mgr) && @school1.has_flag?(School::SUBJECT_MANAGER))
          page.should have_css('select#subject_subject_manager_id.select-select2')
        else
          page.should_not have_css('select#subject_subject_manager_id.select-select2')
        end
        within('h3') do
          page.should have_content('Create Subject')
        end
        within('#new_subject') do
          select(@discipline.name, from: 'subject-discipline-id')
          page.find('input#subject-name', wait: 5).set('Newsubj')
          sleep 1
          page.click_button('Save')
        end
      end

      #page.should have_content("Newsubj")

      # if user is a regular teacher can not perform Edit Subject

      # click on edit subject should show edit subject popup
      page.find("a[href='/subjects/#{@subject1.id}/edit']", wait: 5).click
      within('#modal-body') do
        within('h3') do
          page.should have_content("Edit Subject - #{@subject1.name}")
        end
        within('.edit_subject') do
          #find the properties for NAME and DISCIPLINE to update subject
          select(@discipline.name, from: 'subject-discipline-id')
          page.fill_in 'subject-name', :with => 'Subname'
          sleep 1
          page.click_button('Save')
        end
      end
      page.should have_content("Subname")
    end


    if (can_create_section)
      # note: regular teachers should not be able to create sections (for now)
      this_user.id.should_not equal(@teacher3.id)

      # create section without teaching assignment
      page.find("a[href='/sections/new?subject_id=#{@subject1.id}']", wait: 5).click
      page.find("#modal_content h2.h1 strong", text: "Create Section", wait: 5)
      within("#modal_content") do
        page.find("h2.h1 strong", text: "Create Section")
        page.find('input#section_line_number', wait: 5).set('No Teacher')
        page.click_button('Save')
      end
      page.find("#page-content table tbody tr td.sect-section", text: 'No Teacher', wait: 5)
      # page.should_not have_content(@teacher1.name)
      page.all("td.sect-teacher a", text: @teacher1.full_name, count: 3)

      # create section with teaching assignment
      page.find("a[href='/sections/new?subject_id=#{@subject2.id}']", wait: 5).click
      page.find("#modal_content h2.h1 strong", text: "Create Section", wait: 5)
      within("#modal_content") do
        page.find("h2.h1 strong", text: "Create Section")
        page.find('input#section_line_number', wait: 5).set('With Teacher')
        page.find('#section-assignment-teacher-id option', text: @teacher1.full_name).select_option
        page.click_button('Save')
      end
      page.find('a#expand-all-tbodies', wait: 5).click
      page.find("#page-content table tbody tr td.sect-section", text: 'With Teacher', wait: 5)
      page.all("td.sect-teacher a", text: @teacher1.full_name, count: 4)

      # edit section - add teacher assignment
      page.should have_css("a[data-url='/sections/#{@section2_1.id}/edit.js']")
      find("a[data-url='/sections/#{@section2_1.id}/edit.js']").click
      page.find("tr#sect_#{@section2_1.id}", wait: 5)
      within("tr#sect_#{@section2_1.id}") do
        page.should have_content(@section2_1.line_number)
      end
      within('#modal-body') do
        page.should have_content(@section2_1.subject.name)
        page.should have_selector("#section_line_number[value='#{@section2_1.line_number}']", wait: 5)
        # page.find('input#section_line_number', wait: 5).set('Added Teacher')
        page.find('#section-assignment-teacher-id option', text: @teacher1.full_name).select_option

        within("#section_school_year_id") {page.should have_content("#{@section2_1.school_year.name}")}
        page.click_button('Save')
      end
      page.find('a#expand-all-tbodies', wait: 5).click
      within("tr#sect_#{@section2_1.id}") do
        page.should have_content(@section2_1.line_number)
        page.find("td.sect-teacher a").text.should eq(@teacher1.full_name)
      end
      page.all("td.sect-teacher a", text: @teacher1.full_name, count: 5)

      # edit section - remove teacher assignment
      page.should have_css("a[data-url='/sections/#{@section2_1.id}/edit.js']")
      find("a[data-url='/sections/#{@section2_1.id}/edit.js']").click
      page.find("tr#sect_#{@section2_1.id}", wait: 5)
      within("tr#sect_#{@section2_1.id}") do
        page.should have_content(@section2_1.line_number)
      end
      within('#modal-body') do
        page.should have_content(@section2_1.subject.name)
        page.should have_selector("#section_line_number[value='#{@section2_1.line_number}']", wait: 5)
        page.find('input.remove-teacher').set(true)
        page.click_button('Save')
      end
      page.find('a#expand-all-tbodies', wait: 5).click
      page.all("td.sect-teacher a", text: @teacher1.full_name, count: 4)



    else
      # regular teachers have not been given create or edit section ability
      # puts("+++ cannot create section - this_user: #{this_user.inspect}")
      # puts("+++ cannot create section - regular teacher - @teacher3: #{@teacher3.inspect}")
      page.should_not have_css("a[href='/sections/new?subject_id=#{@subject1.id}']")
      page.should_not have_css("a[data-url='/sections/#{@section1_2.id}/edit.js']")
    end
    # Rails.logger.debug("+++ end has_valid_subjects_listing")
  end # def has_valid_subjects_listing
end
