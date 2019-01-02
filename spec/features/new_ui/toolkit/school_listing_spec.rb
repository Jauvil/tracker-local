# school_listing_spec.rb
require 'spec_helper'

describe "School Listing", js:true do
  describe "US System" do
    before (:each) do
      # @section = FactoryBot.create :section
      # @school = @section.school
      # @teacher = FactoryBot.create :teacher, school: @school
      # @teacher_deact = FactoryBot.create :teacher, school: @school, active: false
      # load_test_section(@section, @teacher)
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: true
      create_and_load_us_model_school

      # @school1
      @school1 = FactoryBot.create :school_current_year, :us
      Rails.logger.debug("+++ school #{@school1.inspect}")
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @section1_2 = FactoryBot.create :section, subject: @subject1
      @section1_3 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline
      load_test_section(@section1_1, @teacher1, false)

      # @school2
      @school2 = FactoryBot.create :school_prior_year, :us
      @teacher2_1 = FactoryBot.create :teacher, school: @school2
      @subject2_1 = FactoryBot.create :subject, school: @school2, subject_manager: @teacher2_1
      @section2_1_1 = FactoryBot.create :section, subject: @subject2_1
      @section2_1_2 = FactoryBot.create :section, subject: @subject2_1
      @section2_1_3 = FactoryBot.create :section, subject: @subject2_1

    end

    describe "as teacher" do
      before do
        sign_in(@teacher1)
        @home_page = "/teachers/#{@teacher1.id}"
      end
      it { has_valid_school_navigations(:teacher) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
        @home_page = "/school_administrators/#{@school_administrator.id}"
      end
      it { has_valid_schools_summary(:school_administrator) }
      it { has_valid_school_navigations(:school_administrator) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
        @home_page = "/researchers/#{@researcher.id}"
      end
      it { has_nav_to_schools_page(true, true) }
      it { has_valid_schools_summary(:researcher) }
      it { has_valid_school_navigations(:researcher) }
    end

    describe "as researcher with no school selected" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        @home_page = "/researchers/#{@researcher.id}"
      end
      it { has_nav_to_schools_page(false, true) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
        @home_page = "/system_administrators/#{@system_administrator.id}"
      end
      it { has_nav_to_schools_page(true, true) }
      it { has_valid_schools_summary(:system_administrator)}
      it { has_valid_school_navigations(:system_administrator) }
      it { valid_edit_school }
    end

    describe "as system administrator with no school selected" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        @home_page = "/system_administrators/#{@system_administrator.id}"
      end
      it { has_nav_to_schools_page(false, true) }
    end

    describe "as student" do
      before do
        sign_in(@student)
        @home_page = "/students/#{@student.id}"
      end
      it { has_valid_school_navigations(:student) }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
        @home_page = "/parents/#{@student.parent.id}"
      end
      it { has_valid_school_navigations(:parent) }
    end
  end

  describe "Egypt System" do
    before (:each) do
      # @section = FactoryBot.create :section
      # @school = @section.school
      # @teacher = FactoryBot.create :teacher, school: @school
      # @teacher_deact = FactoryBot.create :teacher, school: @school, active: false
      # load_test_section(@section, @teacher)
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: false
      create_and_load_arabic_model_school

      # @school1
      @school1 = FactoryBot.create :school_current_year, :arabic
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @section1_2 = FactoryBot.create :section, subject: @subject1
      @section1_3 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline
      load_test_section(@section1_1, @teacher1, false)

      # @school2
      @school2 = FactoryBot.create :school_prior_year, :arabic
      @teacher2_1 = FactoryBot.create :teacher, school: @school2
      @subject2_1 = FactoryBot.create :subject, school: @school2, subject_manager: @teacher2_1
      @section2_1_1 = FactoryBot.create :section, subject: @subject2_1
      @section2_1_2 = FactoryBot.create :section, subject: @subject2_1
      @section2_1_3 = FactoryBot.create :section, subject: @subject2_1

    end

    describe "as teacher" do
      before do
        sign_in(@teacher1)
        @home_page = "/teachers/#{@teacher1.id}"
      end
      it { has_valid_school_navigations(:teacher) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
        @home_page = "/school_administrators/#{@school_administrator.id}"
      end
      it { has_valid_schools_summary(:school_administrator) }
      it { has_valid_school_navigations(:school_administrator) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
        @home_page = "/researchers/#{@researcher.id}"
      end
      it { has_nav_to_schools_page(true, false) }
      it { has_valid_schools_summary(:researcher) }
      it { has_valid_school_navigations(:researcher) }
    end

    describe "as researcher with no school selected" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        @home_page = "/researchers/#{@researcher.id}"
      end
      it { has_nav_to_schools_page(false, false) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
        @home_page = "/system_administrators/#{@system_administrator.id}"
      end
      it { has_nav_to_schools_page(true, false) }
      it { has_valid_schools_summary(:system_administrator)}
      it { has_valid_school_navigations(:system_administrator) }
      it { valid_edit_school }
    end

    describe "as system administrator with no school selected" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        @home_page = "/system_administrators/#{@system_administrator.id}"
      end
      it { has_nav_to_schools_page(false, false) }
    end

    describe "as student" do
      before do
        sign_in(@student)
        @home_page = "/students/#{@student.id}"
      end
      it { has_valid_school_navigations(:student) }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
        @home_page = "/parents/#{@student.parent.id}"
      end
      it { has_valid_school_navigations(:parent) }
    end
  end

  ##################################################
  # test methods

  def has_nav_to_schools_page(school_assigned, show_subject_manager)
    # only for system_administrators and researchers
    if !school_assigned
      # confirm school is not assigned
      within("#head-current-school") do
        page.should have_content("Select a School")
        page.should_not have_content("Switch School")
      end
    end
    page.should have_css("li#side-schools")
    find('li#side-schools a').click
    page.should have_css("a[href='/schools/#{@school2.id}']")
    find("a[href='/schools/#{@school2.id}']").click
    if (show_subject_manager)
      within("#allow-subject-mgr") do
        page.should have_content("true")
      end
    else
      page.should_not have_css("#allow-subject-mgr")
    end
    Rails.logger.debug("+++ server_config #{@server_config.inspect}")


    # confirm school is set
    within("#head-current-school") do
      page.should_not have_content("Select a School")
      within("span[title='Current School']") do
        page.should have_content(@school2.name)
      end
      page.should have_css("a[href='/schools'] i.fa-list-ul")
      page.should have_css("a[href='/schools/#{@school2.id}'] i.fa-building-o")
      page.should have_css("a[href='/schools/#{@school2.id}/dashboard'] i.fa-dashboard")
    end

      # has valid school summary page
      assert_equal("/schools/#{@school2.id}", current_path)
      within("h2") do
        page.should have_content(@school2.name)
      end
      page.should have_css("#summary")
      page.should have_css("#overall")

    end # has_nav_to_schools_page

    def has_valid_schools_summary(role)
      # access to school listing and school summary page in header
      # to be run only for ('system_administrator' || 'researcher' || 'school_administrator')

      # has link to school listing page in header
      if (role == :system_administrator || role == :researcher)
        # note: this is called only after school has been assigned
        page.should have_css("#head-current-school a[href='/schools']")
      elsif (role == :school_administrator)
        page.should_not have_css("#head-current-school a[href='/schools']")
        # if going directly to schools page, should only show one school
        visit schools_path
        assert_equal("/schools", current_path)
        page.should have_css("tr#school-#{@school1.id}")
        page.all("tr td.school-acronym").count.should == 1
      else
        # should not be run for other roles
        assert_equal(false, true)
      end

      # has valid school summary page accessible from header
      within("#head-current-school") do
        find("a[href='/schools/#{@school1.id}']").click
      end

      # validate the school summary page
      assert_equal("/schools/#{@school1.id}", current_path)
      within(".header-block h2") do
        page.should have_content(@school1.name)
      end
      within("#overall #school-acronym") do
        page.should have_content(@school1.acronym)
      end
      within("#summary") do
        page.should have_css("a[href='/schools/#{@school1.id}/dashboard']")
        page.should have_css("a[href='/teachers/tracker_usage']")
        page.should have_css("a[href='/subjects/progress_meters']")
        page.should have_css("a[href='/subjects/proficiency_bars']")
        # to do - create staff activity report as in school dashboard page, except more/all? recent activity
        # page.should have_css("a[href='/users/staff_activity_report']")
        if role == :researcher
          page.should_not have_css("a[href='/students/reports/proficiency_bar_chart']")
          page.should_not have_css("a[href='/users/account_activity_report']")
        else
          page.should have_css("a[href='/students/reports/proficiency_bar_chart']")
          page.should have_css("a[href='/users/account_activity_report']")
        end
      end
      within("#overall #school-details") do
        within('#school-name') do
          page.should have_content(@school1.name)
        end
        page.should have_css('#school-name', text: @school1.name)
        page.should have_css('#school-acronym', text: @school1.acronym)
        page.should have_css('#school-city', text: @school1.city)
        if role == :system_administrator
          within('#school-marking-periods') { page.should have_content(@school1.marking_periods) }
          if (ServerConfig.first.try(:allow_subject_mgr) != true)
            page.should_not have_content("Allow Subject Managers")
          else
            within('#allow-subject-mgr') { page.should have_content(@school1.has_flag?(School::SUBJECT_MANAGER)) }
          end
          within('#school-use-family-name') { page.should have_content(@school1.has_flag?(School::USE_FAMILY_NAME)) }
          within('#school-sort-by') { page.should have_content(@school1.has_flag?(School::USER_BY_FIRST_LAST)) }
          within('#school-grade-in-subject') { page.should have_content(@school1.has_flag?(School::GRADE_IN_SUBJECT_NAME)) }
          within('#username-from-email') { page.should have_content(@school1.has_flag?(School::USERNAME_FROM_EMAIL)) }
        else
          page.should_not have_css('#school-marking-periods')
          if (ServerConfig.first.try(:allow_subject_mgr) != true)
            page.should_not have_css('#allow-subject-mgr') #egypt school system
          else
            page.should have_css('#allow-subject-mgr') #us school system
          end
          page.should_not have_css('#school-use-family-name')
          page.should_not have_css('#school-sort-by')
          page.should_not have_css('#school-grade-in-subject')
          page.should_not have_css('#username-from-email')
        end
        page.should have_css('#school-year-start', text: "#{@school1.school_year.start_mm}-#{@school1.school_year.start_yyyy}")
        page.should have_css('#school-year-end', text: "#{@school1.school_year.end_mm}-#{@school1.school_year.end_yyyy}")
      end

    end # has_valid_schools_summary

    def has_valid_school_navigations(role)
      # confirm sidebar only shows the school listing toolkit item if allowed
      if (role == :system_administrator || role == :researcher)
        page.should have_css("li#side-schools a[href='/schools']")
      else
        page.should_not have_css("li#side-schools")
        page.should_not have_css("a[href='/schools']")
      end

      # confirm header has correct icons and links for current school.
      within("#head-current-school") do
        page.should_not have_content("Select a School")
        within("span[title='Current School']") do
          page.should have_content(@school1.name)
        end
        if (role == :system_administrator || role == :researcher)
          page.should have_css("a[href='/schools'] i.fa-list-ul")
        else
          page.should_not have_css("a[href='/schools']")
          page.should_not have_css("a[href='/schools'] i.fa-list-ul")
        end
        if (role == :system_administrator || role == :researcher || role == :school_administrator)
          page.should have_css("a[href='/schools/#{@school1.id}'] i.fa-building-o")
          page.should have_css("a[href='/schools/#{@school1.id}/dashboard'] i.fa-dashboard")
        else
          page.should_not have_css("a[href='/schools/#{@school1.id}']")
          page.should_not have_css("a[href='/schools/#{@school1.id}'] i.fa-building-o")
          page.should_not have_css("a[href='/schools/#{@school1.id}/dashboard']")
          page.should_not have_css("a[href='/schools/#{@school1.id}/dashboard'] i.fa-dashboard")
        end
      end

      # Check go to school listing via navigation if available, else visit via URL
      if (role == :system_administrator || role == :researcher)
        within("#head-current-school") do
          find("a[href='/schools'] i.fa-list-ul").click
        end
      else
        visit(schools_path)
      end

      # validate the school listing page (if available)
      if (role == :student || role == :parent)
        assert_equal(current_path, @home_page)
      else
        assert_equal(current_path, schools_path)

        # ensure only valid links are displayed for school 1 based upon role.
        if (role == :teacher || role == :school_administrator || role == :system_administrator || role == :researcher)
          within("tr#school-#{@school1.id}") do
            # all of these users should not have an active new year rollover
            page.should_not have_css("a[href='/schools/#{@school1.id}/new_year_rollover']")
            if (role == :teacher)
              page.should_not have_css("a[href='/schools/#{@school1.id}'] i.fa-building-o")
              page.should_not have_css("a[href='/schools/#{@school1.id}/dashboard'] i.fa-dashboard")
              page.should_not have_css("a[data-url='/schools/#{@school1.id}/edit.js']")
              page.should_not have_css("i.fa-edit")
              page.should_not have_css("a[id='rollover-#{@school1.id}']")
            elsif (role == :researcher)
              page.should have_css("a[href='/schools/#{@school1.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@school1.id}/dashboard'] i.fa-dashboard")
              page.should_not have_css("a[data-url='/schools/#{@school1.id}/edit.js']")
              page.should_not have_css("i.fa-edit")
              page.should_not have_css("a[id='rollover-#{@school1.id}']")
            elsif (role == :school_administrator)
              page.should have_css("a[href='/schools/#{@school1.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@school1.id}/dashboard'] i.fa-dashboard")
              page.should_not have_css("a[data-url='/schools/#{@school1.id}/edit.js']")
              page.should_not have_css("i.fa-edit")
              page.should have_css("a.dim[id='rollover-#{@school1.id}'][href='javascript:void(0)'] i.fa-forward")
            elsif (role == :system_administrator)
              page.should have_css("a[href='/schools/#{@school1.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@school1.id}/dashboard'] i.fa-dashboard")
              page.should have_css("a[data-url='/schools/#{@school1.id}/edit.js'] i.fa-edit")
              page.should have_css("a.dim[id='rollover-#{@school1.id}'][href='javascript:void(0)'] i.fa-forward")
            end
          end

          # validate only/all other schools are listed and links are valid
          if (role == :teacher || role == :school_administrator)
            page.should have_css("tr#school-#{@school1.id}")
            page.all("tr td.school-acronym").count.should == 1
          elsif (role == :system_administrator || role == :researcher)
            page.should have_css("tr#school-#{@school1.id}")
            page.should have_css("tr#school-#{@school2.id}")
            page.should have_css("tr#school-#{@model_school.id}")
            page.should have_css("tr#school-#{@training_school.id}")
            page.all("tr td.school-acronym").count.should == 4
            if (role == :system_administrator)
              page.should have_css("a[href='/schools/#{@school2.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@school2.id}/dashboard'] i.fa-dashboard")
              page.should have_css("a[data-url='/schools/#{@school2.id}/edit.js'] i.fa-edit")
              page.should have_css("a[id='rollover-#{@school2.id}'][href='/schools/#{@school2.id}/new_year_rollover'] i.fa-forward")
              page.should have_css("a[href='/schools/#{@model_school.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@model_school.id}/dashboard'] i.fa-dashboard")
              page.should have_css("a[data-url='/schools/#{@model_school.id}/edit.js'] i.fa-edit")
              page.should have_css("a[id='rollover-#{@model_school.id}'][href='/schools/#{@model_school.id}/new_year_rollover'] i.fa-forward")
              page.should have_css("a[href='/schools/#{@training_school.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@training_school.id}/dashboard'] i.fa-dashboard")
              page.should have_css("a[data-url='/schools/#{@training_school.id}/edit.js'] i.fa-edit")
              page.should have_css("a[id='rollover-#{@training_school.id}'][href='/schools/#{@training_school.id}/new_year_rollover'] i.fa-forward")
              page.should have_css("a[href='/subject_outcomes/upload_lo_file'] i.fa-lightbulb-o")
            elsif (role == :researcher)
              page.should have_css("a[href='/schools/#{@school2.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@school2.id}/dashboard'] i.fa-dashboard")
              page.should_not have_css("a[data-url='/schools/#{@school2.id}/edit.js']")
              page.should_not have_css("a[href='/schools/#{@school2.id}/new_year_rollover']")
              page.should_not have_css("a[id='rollover-#{@school2.id}']")
              page.should have_css("a[href='/schools/#{@model_school.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@model_school.id}/dashboard'] i.fa-dashboard")
              page.should_not have_css("a[data-url='/schools/#{@model_school.id}/edit.js']")
              page.should_not have_css("a[href='/schools/#{@model_school.id}/new_year_rollover']")
              page.should_not have_css("a[id='rollover-#{@model_school.id}']")
              page.should have_css("a[href='/schools/#{@training_school.id}'] i.fa-building-o")
              page.should have_css("a[href='/schools/#{@training_school.id}/dashboard'] i.fa-dashboard")
              page.should_not have_css("a[data-url='/schools/#{@training_school.id}/edit.js']")
              page.should_not have_css("a[href='/schools/#{@training_school.id}/new_year_rollover']")
              page.should_not have_css("a[id='rollover-#{@training_school.id}']")
              page.should_not have_css("a[href='/subject_outcomes/upload_lo_file'] i.fa-lightbulb-o")
            end
          end
        else
          # no tests for other roles yet
        end
      end
    end # has_valid_school_navigations

    def valid_edit_school
      # validate if edit school dialog should display, and if so does it work properly
      visit schools_path
      Rails.logger.debug("+++ stage editing")

      find("a[data-url='/schools/#{@school1.id}/edit.js'] i.fa-edit").click
      page.should have_content("Edit School")

      within("#modal_popup .modal-dialog .modal-content .modal-body") do
        within("form#edit_school_#{@school1.id}") do
          Rails.logger.debug("+++ start edit")
          # page.select(@subject2_1.discipline.name, from: "subject-discipline-id")
          page.fill_in 'school_name', :with => 'New-School'
          page.fill_in 'school_acronym', :with => 'CHANGED'
          page.fill_in 'school_city', :with => 'Changed-City'
          page.fill_in 'school_marking_periods', :with => '4'
          if (ServerConfig.first.try(:allow_subject_mgr) != true)
            page.should_not have_content("Allow Subject Managers")
          else
            #find_field("school[flag_pars][subject_manager]").value.should == 'on'
            find("input[name='school[flag_pars][subject_manager]']").set(true)
          end
          find_field("school[flag_pars][use_family_name]").value.should == 'on'
          find("input[name='school[flag_pars][use_family_name]']").set(false)
          find_field("school[flag_pars][user_by_first_last]").value.should == 'on'
          find("input[name='school[flag_pars][user_by_first_last]']").set(false)
          select "8", from: "min_grade"
          select "11", from: "max_grade"
          find_field("school[flag_pars][grade_in_subject_name]").value.should == 'on'
          find("input[name='school[flag_pars][grade_in_subject_name]']").set(false)
          find_field("school[flag_pars][username_from_email]").value.should == 'on'
          find("input[name='school[flag_pars][username_from_email]']").set(false)
          find("input#school_start_mm").set('10')
          find("input#school_start_yyyy").set('2001')
          find("input#school_end_mm").set('5')
          find("input#school_end_yyyy").set('2002')
          Rails.logger.debug("+++ finish editing")
          sleep 1
          page.click_button('Save')
        end
      end

      page.should_not have_css("#modal_popup form#edit_school_#{@school2.id}")
      assert_equal("/schools", current_path)
      sleep 15
      find("a[data-url='/schools/#{@school1.id}/edit.js'] i.fa-edit").click
      page.should have_content("Edit School")
      Rails.logger.debug("+++ check to see subj manager is on")

      within("#modal_popup .modal-dialog .modal-content .modal-body") do
        sleep 1
        page.should have_css('input#school_name')
        find_field("school_name").value.should_not == @school2.name
        find_field("school_name").value.should == 'New-School'
        find_field("school_acronym").value.should == 'CHANGED'
        find_field("school_city").value.should == 'Changed-City'
        find_field("school_marking_periods").value.should == '4'
        if (ServerConfig.first.try(:allow_subject_mgr) != true)
          page.should_not have_content("Allow Subject Managers")
        else
          expect(page).to have_field('school[flag_pars][subject_manager]', checked: true)
        end
        find_field("school[flag_pars][use_family_name]").value.should == 'on'
        find_field("school[flag_pars][user_by_first_last]").value.should == 'on'
        expect(page).to have_field('school[flag_pars][use_family_name]', checked: false)
        expect(page).to have_field('school[flag_pars][user_by_first_last]', checked: false)
        expect(page).to have_select('school[min_grade]', selected: '8')
        expect(page).to have_select('school[max_grade]', selected: '11')
        expect(page).to have_field('school[flag_pars][grade_in_subject_name]', checked: false)
        find_field("school[flag_pars][username_from_email]").value.should == 'on'
        find_field("school_start_mm").value.should == '10'
        find_field("school_start_yyyy").value.should == '2001'
        find_field("school_end_mm").value.should == '5'
        find_field("school_end_yyyy").value.should == '2002'
        Rails.logger.debug("+++ edit check")
        sleep 1
        page.click_button('Save')
      end

      assert_equal("/schools", current_path)

      within("tr#school-#{@school1.id}") do
        page.should have_content("New-School")
        page.should have_content("CHANGED")
        page.should have_content("Changed-City")
        page.should have_content("2001-2002")
        find("a[href='/schools/#{@school1.id}']").click
      end
      assert_equal("/schools/#{@school1.id}", current_path)

      page.should have_css('#school-name', text: "New-School")
      page.should have_css('#school-acronym', text: "CHANGED")
      page.should have_css('#school-city', text: "Changed-City")
      if (ServerConfig.first.try(:allow_subject_mgr) != true)
        page.should_not have_content("Allow Subject Managers")
        page.should have_css('#school-use-family-name', text: "true")
        page.should have_css('#school-sort-by', text: "true")
        page.should have_css('#username-from-email', text: "true")
      else
      page.should have_css('#allow-subject-mgr', text: "true")
      page.should have_css('#school-use-family-name', text: "false")
      page.should have_css('#school-sort-by', text: "false")
      page.should have_css('#username-from-email', text: "false")
      end
      page.should have_css('#school-marking-periods', text: "4")
      page.should have_css('#school-min-grade', text: "8")
      page.should have_css('#school-max-grade', text: "11")
      page.should have_css('#school-grade-in-subject', text: "true")
      page.should have_css('#school-year-start', text: "10-2001")
      page.should have_css('#school-year-end', text: "5-2002")
    end # end valid_edit_school
  end
