# staff_listing_spec.rb
require 'rails_helper'
describe "Staff Listing", js:true do
  describe "US System" do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: true
      create_and_load_us_model_school
      @school = FactoryBot.create :school_prior_year, :us
      @teacher = FactoryBot.create :teacher, school: @school
      @teacher_deact = FactoryBot.create :teacher, school: @school, active: false
      @subject = FactoryBot.create :subject, school: @school, subject_manager: @teacher
      @section = FactoryBot.create :section, subject: @subject
      @discipline = @subject.discipline
      load_test_section(@section, @teacher)
      @system_administrator = FactoryBot.create :system_administrator
      @school_administrator = FactoryBot.create :school_administrator, school: @school
      # to do - requirements for who can see and edit researchers
      @researcher = FactoryBot.create :researcher
      # to do - requirements for who can see and edit counselors
      @counselor = FactoryBot.create :counselor, school: @school

      # go to new year
      set_current_school_year(@school)
      @sectiony2 = FactoryBot.create :section, subject: @subject
      load_test_section_yr2(@sectiony2, @teacher)
    end
    describe "as teacher" do
      before do
        sign_in(@teacher)
      end
      it { has_valid_staff_listing(:teacher) }
      skip { can_see_counselors()}
    end
    describe "as school administrator" do
      before do
        sign_in(@school_administrator)
      end
      it { has_valid_staff_listing(:school_administrator) }
      skip { can_see_counselors()}
    end
    # to do - do this once toolkit and home page for counselor exists
    # describe "as counselor" do
    #   before do
    #     @counselor = FactoryBot.create :counselor, school: @school
    #     sign_in(@counselor)
    #   end
    #   it { has_valid_staff_listing(:counselor) }
    # end
    describe "as researcher" do
      before do
        sign_in(@researcher)
        set_users_school(@school)
      end
      it { has_valid_staff_listing(:researcher) }
      skip { can_see_counselors()}
    end
    describe "as system administrator" do
      before do
        sign_in(@system_administrator)
        set_users_school(@school)
      end
      it { has_valid_staff_listing(:system_administrator) }
      skip { can_edit_counselors()}
    end
    describe "as student" do
      before do
        sign_in(@student)
      end
      it { has_no_staff_listing }
      skip { cannot_see_counselors()}
    end
    describe "as parent" do
      before do
        sign_in(@student.parent)
      end
      it { has_no_staff_listing }
      skip { cannot_see_counselors()}
    end
  end
  describe "Egypt System" do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: false
      create_and_load_arabic_model_school
      @school = FactoryBot.create :school_prior_year, :arabic
      @teacher = FactoryBot.create :teacher, school: @school
      @teacher_deact = FactoryBot.create :teacher, school: @school, active: false
      @subject = FactoryBot.create :subject, school: @school, subject_manager: @teacher
      @section = FactoryBot.create :section, subject: @subject
      @discipline = @subject.discipline
      load_test_section(@section, @teacher)
      @system_administrator = FactoryBot.create :system_administrator
      @school_administrator = FactoryBot.create :school_administrator, school: @school
      # to do - requirements for who can see and edit researchers
      @researcher = FactoryBot.create :researcher
      # to do - requirements for who can see and edit counselors
      @counselor = FactoryBot.create :counselor, school: @school

      # go to new year
      set_current_school_year(@school)
      @sectiony2 = FactoryBot.create :section, subject: @subject
      load_test_section_yr2(@sectiony2, @teacher)

    end
    describe "as teacher" do
      before do
        sign_in(@teacher)
      end
      it { has_valid_staff_listing(:teacher) }
      skip { can_see_counselors()}
    end
    describe "as school administrator" do
      before do
        sign_in(@school_administrator)
      end
      it { has_valid_staff_listing(:school_administrator) }
      skip { can_see_counselors()}
    end
    # to do - do this once toolkit and home page for counselor exists
    # describe "as counselor" do
    #   before do
    #     @counselor = FactoryBot.create :counselor, school: @school
    #     sign_in(@counselor)
    #   end
    #   it { has_valid_staff_listing(:counselor) }
    # end
    describe "as researcher" do
      before do
        sign_in(@researcher)
        set_users_school(@school)
      end
      it { has_valid_staff_listing(:researcher) }
      skip { can_see_counselors()}
    end
    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school)
      end
      it { has_valid_staff_listing(:system_administrator) }
      skip { can_edit_counselors()}
      skip { test_somewhere_add_user_without_email }
    end
    describe "as student" do
      before do
        sign_in(@student)
      end
      it { has_no_staff_listing }
      skip { cannot_see_counselors()}
    end
    describe "as parent" do
      before do
        sign_in(@student.parent)
      end
      it { has_no_staff_listing }
      skip { cannot_see_counselors()}
    end
  end


  ##################################################
  # test methods

  def cannot_see_counselors
    # need requirements for this (note US may be different from EG)
  end

  def can_see_counselors
    # need requirements for this (note US may be different from EG)
  end

  def can_edit_counselors
    # need requirements for this (note US may be different from EG)
  end

  def test_somewhere_add_user_without_email
    # this is a reminder to ensure that there are tests to make sure that missing email addresses in schools requiring emails generate an error.
  end

  def has_no_staff_listing
    visit staff_listing_users_path
    assert_not_equal("/users/staff_listing", current_path)
  end

  def has_valid_staff_listing(role)
    visit staff_listing_users_path
    assert_equal("/users/staff_listing", current_path)

    #########################
    # Initial counts of users who are active or deactivated
    page.all("tbody.tbody-body tr.active").length.should == 3
    page.all("tbody.tbody-body tr.deactivated").length.should == 1

    within("#page-content") do
      page.should have_content("All Staff for #{@school.name}")
      page.should have_css("tr#user_#{@teacher.id}")
      page.find("tr#user_#{@teacher.id}", wait: 2)
      page.should_not have_css("tr#user_#{@teacher.id}.deactivated")
      page.should have_css("tr#user_#{@teacher.id}.active")
      within("tr#user_#{@teacher.id}") do
        page.should have_content("#{@teacher.last_name}")
        page.should have_content("#{@teacher.first_name}")
        page.should have_content("#{@teacher.email}")
        within("td.user-assignment-count") do
          page.should have_content("1")
        end
      end
    end
    ########################
    # Dashboard visiblity and availability testing
    # all who can see staff listing (teachers, admins, counselor, researcher) can see any teacher's dashboard
    within("#page-content") do
      within("tr#user_#{@teacher.id}") do
        page.should have_css("a[href='/users/#{@teacher.id}'] i.fa-dashboard")
        # removed this due to issues with scrolling to link
        # if needed can visit /users/#{@teacher.id}
        # page.find("a[href='/users/#{@teacher.id}']", match: :first, wait: 10).click
      end
    end
    # removed this due to issues with scrolling to link above
    # # note will get redirected to primary role for user, in this case is teacher
    # assert_equal("/teachers/#{@teacher.id}", current_path)
    # page.should have_content("Teacher: #{@teacher.full_name}")

    ########################
    # Section Listing visiblity and availability testing
    # teachers can see section listing or tracker pages that are their own
    # all others who can see staff listing (admins, counselor, researcher) can see them
    visit staff_listing_users_path
    assert_equal("/users/staff_listing", current_path)
    within("#page-content") do
      within("tr#user_#{@teacher.id}") do
        page.find("a[href='/users/#{@teacher.id}/sections_list'] i.fa-check", wait: 2)
        page.should have_css("a[href='/users/#{@teacher.id}/sections_list'] i.fa-check")
        page.find("a[href='/users/#{@teacher.id}/sections_list']").click
      end
    end
    assert_equal("/users/#{@teacher.id}/sections_list", current_path)
    page.should have_content("All Sections for staff member: #{@teacher.full_name}")
    within("#section_#{@section.id}") do
      page.should have_css("a[href='/sections/#{@section.id}']")
    end
    # teachers cannot see section listing or tracker pages that are not their own
    if [:teacher].include?(role)
      visit staff_listing_users_path
      assert_equal("/users/staff_listing", current_path)
      within("#page-content") do
        within("tr#user_#{@teacher_deact.id}") do
          page.should_not have_css("a[href='/users/#{@teacher_deact.id}/sections_list'] i.fa-check")
        end
      end
    end
    ########################
    # View Staff Information visiblity and availability testing
    # teachers can see their own user information
    # all others who can see staff listing (admins, counselor, researcher) can see any user's information
    visit staff_listing_users_path
    assert_equal("/users/staff_listing", current_path)
    within("#page-content") do
      within("tr#user_#{@teacher.id}") do
        page.should have_css("i.fa-ellipsis-h")
        page.should have_css("a[data-url='/users/#{@teacher.id}.js'] i.fa-ellipsis-h")
        page.find("a[data-url='/users/#{@teacher.id}.js']").click
      end
    end
    within("#modal_popup") do
      page.find("h2#user-name", wait: 3)
      page.should have_content('View Staff')
      page.should have_content(@teacher.first_name)
      page.should have_content(@teacher.last_name)
      # page.should have_css("button", text: 'Cancel')
      find("button", text: 'Cancel').click
    end
    # teachers cannot see other user's information
    if [:teacher].include?(role)
      # visit staff_listing_users_path
      assert_equal("/users/staff_listing", current_path)
      within("#page-content") do
        within("tr#user_#{@teacher_deact.id}") do
          page.should_not have_css("i.fa-ellipsis-h")
          page.should_not have_css("a[data-url='/users/#{@teacher_deact.id}.js'] i.fa-ellipsis-h")
        end
      end
    end
    ########################
    # Edit Staff Information visiblity and availability testing
    # Change Staff Role test
    # teachers can edit their own user information for themselves
    # admins can edit all staff user information
    # visit staff_listing_users_path
    if [:teacher, :school_administrator, :system_administrator].include?(role)
      assert_equal("/users/staff_listing", current_path)
      within("#page-content") do
        within("tr#user_#{@teacher.id}") do
          page.should have_css("i.fa-edit")
          page.find("a[data-url='/users/#{@teacher.id}/edit.js']", wait: 5).click
        end
      end
      within("#modal_popup") do
        # page.should have_css('#staff_first_name', value: @teacher.first_name)
        # page.should have_css('#staff_last_name', value: @teacher.last_name)
        within('h3') do
          page.should have_content(@teacher.first_name)
          page.should have_content(@teacher.last_name)
        end
        page.find("h2", text: 'Edit Staff', wait: 5)
        # page.should have_css("h2", text: 'Edit Staff')
        within("form#edit_user_#{@teacher.id}") do
          # ensure that only the admins can choose roles in edit form
          if [:school_administrator, :system_administrator].include?(role)
            assert_equal(page.all("fieldset.role-field").count.should, 3)
            page.should have_css('fieldset#role-sch-admin')
            page.should have_css('fieldset#role-teach')
            page.should have_css('fieldset#role-couns')
            # Update roles
            uncheck('user[teacher]')
            check('user[counselor]')
            # add counselor role to @teacher
          else # teacher editing
            assert_equal(page.all("fieldset.role-field").count.should, 0)
            page.should_not have_css('fieldset#role-sch-admin')
            page.should_not have_css('fieldset#role-teach')
            page.should_not have_css('fieldset#role-couns')
          end
          page.fill_in 'staff_first_name', :with => 'Changed First Name'
          page.fill_in 'staff_last_name', :with => 'Changed Last Name'
        # always added email, because tests are not finding error message in div.ui-error
        # should have test for missing email error for schools requiring email addresses
        page.fill_in 'staff_email', :with => 'changed@sample.com'
          page.should have_css("button", text: 'Save')
          find("button", text: 'Save').click
        end
      end

      assert_equal("/users/staff_listing", current_path)
      # Ensure first and last names changed
      within("#page-content table #user_#{@teacher.id}") do
        page.should have_css('.user-first-name', 'Changed First Name')
        page.should have_css('.user-last-name', 'Changed Last Name')
        # Ensure role, changed from teacher to counselor if administrator
        within('.user-roles') do
          if [:school_administrator, :system_administrator].include?(role)
            page.should have_content('counselor')
          else
            page.should_not have_content('counselor')
          end
        end
      end
    end


    # teachers and counselors cannot edit other user's information
    # researchers cannot edit any user's information
    if [:teacher, :counselor, :researcher].include?(role)
      # visit staff_listing_users_path
      # assert_equal("/users/staff_listing", current_path)
      within("#page-content tr#user_#{@teacher_deact.id}") do
        page.should_not have_css("i.fa-edit")
        page.should_not have_css("a[data-url='/users/#{@teacher_deact.id}.js'] i.fa-edit")
      end
    end
    ########################
    # Staff Security Information visiblity and availability testing
    # Only admins can view and reset security information for staff
    # visit staff_listing_users_path
    if [:school_administrator, :system_administrator].include?(role)
      assert_equal("/users/staff_listing", current_path)
      page.find("#page-content tr#user_#{@teacher.id}", wait: 2)
      within("#page-content tr#user_#{@teacher.id}") do
        page.should have_css("i.fa-unlock")
        page.should have_css("a[data-url='/users/#{@teacher.id}/security.js'] i.fa-unlock")
        page.find("a[data-url='/users/#{@teacher.id}/security.js']").click
      end
      within("#modal_popup") do
        page.should have_css("h2", text: 'Staff Security and Access')
        within("#modal-body table") do
          page.should have_content(@teacher.username)
        end
        page.find(".modal-footer button", text: 'Close').click
      end
      assert_equal("/users/staff_listing", current_path)
    else
      assert_equal("/users/staff_listing", current_path)
      within("#page-content") do
        within("tr#user_#{@teacher.id}") do
          page.should_not have_css("i.fa-unlock")
          page.should_not have_css("a[data-url='/users/#{@teacher.id}/security.js']")
        end
      end
    end

    #########################
    # Initial counts of users who are active or deactivated
    page.all("tbody.tbody-body tr.active").length.should == 3
    page.all("tbody.tbody-body tr.deactivated").length.should == 1

    #########################
    # only admins can deactivate or reactivate staff members
    if [:teacher, :counselor, :researcher].include?(role)
      visit staff_listing_users_path
      assert_equal("/users/staff_listing", current_path)
      within("#page-content tr#user_#{@teacher.id}") do
        page.should_not have_css("#remove-staff")
      end
    elsif [:school_administrator, :system_administrator].include?(role)
      visit staff_listing_users_path
      assert_equal("/users/staff_listing", current_path)
      within("#page-content tr#user_#{@teacher.id}") do
        # click the deactivate icon
        find('#remove-staff').click
        page.driver.browser.switch_to.alert.accept
      end
      # confirm the teacher is deactivated
      page.should have_css("tr#user_#{@teacher.id}.deactivated")
      page.should_not have_css("tr#user_#{@teacher.id}.active")
      # reactivate the originally deactivated teacher
      page.should have_css("tr#user_#{@teacher_deact.id}")
      page.should have_css("tr#user_#{@teacher_deact.id}.deactivated")
      page.should_not have_css("tr#user_#{@teacher_deact.id}.active")
      within("tr#user_#{@teacher_deact.id}") do
        page.should have_content("#{@teacher_deact.last_name}")
        page.should have_content("#{@teacher_deact.first_name}")
        page.should have_content("#{@teacher_deact.email}")
      end
      # click the reactivate icon
      within("tr#user_#{@teacher_deact.id}") do
        find('#restore-staff').click
        page.driver.browser.switch_to.alert.accept
      end
      # confirm the user is deactivated
      page.should have_css("tr#user_#{@teacher_deact.id}.active")
      page.should_not have_css("tr#user_#{@teacher_deact.id}.deactivated")
    else
      # no other roles should be tested here
      assert_equal(true, false)
    end # within("#page-content") do

    #########################
    # check of counts of users who are active or deactivated
    page.all("tbody.tbody-body tr.active").length.should == 3
    page.all("tbody.tbody-body tr.deactivated").length.should == 1

    ########################
    # Add New Staff visiblity and availability testing
    # Only admins can create new staff
    # Add New Staff and check Error for not adding role while adding a new staff
    assert_equal("/users/staff_listing", current_path)
    if [:school_administrator, :system_administrator].include?(role)
      within("#page-content #button-block") do
        page.should have_css("i.fa-plus-square")
        page.should have_css("a[data-url='/users/new/new_staff'] i.fa-plus-square")
        page.find("a[data-url='/users/new/new_staff']").click
        page.should have_css("a#upload-staff")
      end

      within("#modal_popup") do
        page.should have_css("h2", text: 'Create Staff Member')
        # Make sure all roles are unchecked and error is showing
        page.find("#staff_first_name", wait: 2)
        expect(page).to have_field('user[school_administrator]', checked: false)
        expect(page).to have_field('user[teacher]', checked: false)
        expect(page).to have_field('user[counselor]', checked: false)
        page.fill_in 'staff_first_name', :with => 'First Name'
        page.fill_in 'staff_last_name', :with => 'Last Name'
        # always added email, because tests are not finding error message in div.ui-error
        # should have test for missing email error for schools requiring email addresses
        page.fill_in 'staff_email', :with => 'changed@sample.com'
        page.find("button", text: 'Save').click
        err_elem = page.find('div.ui-error', match: :first, wait: 5)
        within(err_elem) do
          page.should have_content('There are Errors')
        end
        find("button", text: 'Cancel', wait: 2).click
      end

      # check of counts of users who are active or deactivated
      page.all("tbody.tbody-body tr.active").length.should == 3
      page.all("tbody.tbody-body tr.deactivated").length.should == 1

      # Add Staff
      assert_equal("/users/staff_listing", current_path)
      within("#page-content #button-block") do
        page.find("a[data-url='/users/new/new_staff']", wait: 2).click
      end
      sleep 2
      within("#modal_popup") do
        # Add teacher
        find("#staff_first_name", wait: 2)
        find("input[name='user[teacher]']").set(true)
        page.fill_in 'staff_first_name', :with => 'FN'
        page.fill_in 'staff_last_name', :with => 'LN'
        # always added email, because tests are not finding error message in div.ui-error
        # should have test for missing email error for schools requiring email addresses
        page.fill_in 'staff_email', :with => 'new@sample.com'
        page.should have_css("button", text: 'Save')
        find("button", text: 'Save').click
      end
      sleep 2
      # check if new teacher was added
      assert_equal("/users/staff_listing", current_path)
      page.all("tbody.tbody-body tr.active").length.should == 4
      within("#page-content") do
          page.should have_content("FN")
          page.should have_content("LN")
      end
      # check of counts of users who are active or deactivated
      page.all("tbody.tbody-body tr.active").length.should == 4
      page.all("tbody.tbody-body tr.deactivated").length.should == 1

      #Setup for bulk upload tests
      store_school_data = [@school.acronym, @school.name]
      reset_school_acronym_and_name(@school, "TEST", "Factory School")
      upload_table_columns = ['Line', 'Username', 'First Name', 'Acronym', 'Email', 'Position', 'Errors']
      
      ##############################
      # Check Bulk Upload Staff is working for valid .csv file in preview mode
      # ############################
      
      #visit bulk upload file selection page 
      do_bulk_upload(true) #in_preview_mode == true

      page.should have_content("Staff Bulk Upload")
      page.should have_css("div.upload-output#show-details .table-title")
      page.should_not have_css("#show-errors h3.ui-error.text-right")
      page.should_not have_css("td span.ui-error")
      upload_table_columns.each do |col_name|
        page.should have_css('th', text: col_name)
      end

      ##############################
      # Check Bulk Upload Staff is working for valid .csv file in save mode
      # ############################
      
      do_bulk_upload(false) #in_preview_mode == false
      page.find('.show_report_btn', text: "Show entered report").click
      
      page.should have_content("Staff Bulk Upload")
      page.should have_css("div.upload-output#show-details .table-title")
      page.should_not have_css("#show-errors h3.ui-error.text-right")
      page.should_not have_css("td span.ui-error")
      upload_table_columns.each do |col_name|
        page.should have_css('th', text: col_name)
      end

      visit staff_listing_users_path
      within("tr", text: "Fahmy") do 
        page.should have_content("Hamada")
        page.should have_content("school_administrator")
        page.should have_content("principal@stemegypt.edu.eg")
      end 
      within("tr", text: "Abbas Naeem") do 
        page.should have_content("Mahmoud")
        page.should have_content("teacher")
        page.should have_content("mahmoud.abbas@stemegypt.edu.eg")
      end 

      # undo setup for bulk upload tests to avoid duplicate school names and acronyms
      reset_school_acronym_and_name(@school, store_school_data[0], store_school_data[1])

    else # not an administrator, cannot add new staff
      within("#page-content #button-block") do
        page.should_not have_css("i.fa-plus-square")
        page.should_not have_css("a[data-url='/users/new/new_staff'] i.fa-plus-square")
        page.should_not have_css("a#upload-staff")
      end
    end
  end # def has_valid_subjects_listing

  def do_bulk_upload(in_preview_mode)
      visit staff_listing_users_path
      page.find("a#upload-staff").click

      #attach csv file to form and show 'Preview' option
      page.attach_file('file', File.join(Rails.root, '/spec/fixtures/files/StaffDataUploadValidForTest.csv'))
      page.execute_script("$('#show-upload').show()")
      page.find('#show-upload input[type=checkbox]').set(in_preview_mode)
      page.find('button#upload').click
  end

end