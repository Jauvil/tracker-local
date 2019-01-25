# announcements_spec.rb
require 'spec_helper'


describe "Announcements", js:true do
  describe "US System", js:true do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: true
      create_and_load_us_model_school

      # @school1
      @school1 = FactoryBot.create :school_current_year, :us
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline
      load_test_section(@section1_1, @teacher1)

      @announcement1 = FactoryBot.create :announcement
      @announcement2 = FactoryBot.create :announcement
    end


    describe "as teacher" do
      before do
        sign_in(@teacher1)
        @home_page = "/teachers/#{@teacher1.id}"
      end
      it { has_valid_announcements(:teacher) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
        @home_page = "/school_administrators/#{@school_administrator.id}"
      end
      it { has_valid_announcements(:school_administrator) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
        @home_page = "/researchers/#{@researcher.id}"
      end
      it { has_valid_announcements(:researcher) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
        @home_page = "/system_administrators/#{@system_administrator.id}"
      end
      it { has_valid_announcements(:system_administrator) }
    end

    describe "as student" do
      before do
        sign_in(@student)
        @home_page = "/students/#{@student.id}"
      end
      it { has_valid_announcements(:student) }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
        @home_page = "/parents/#{@student.parent.id}"
      end
      it { has_valid_announcements(:parent) }
    end
  end

  describe "Egypt System", js:true do
    before (:each) do
      @server_config = FactoryBot.create :server_config, allow_subject_mgr: false
      create_and_load_arabic_model_school

      # @school1
      @school1 = FactoryBot.create :school_current_year, :arabic
      @teacher1 = FactoryBot.create :teacher, school: @school1
      @subject1 = FactoryBot.create :subject, school: @school1, subject_manager: @teacher1
      @section1_1 = FactoryBot.create :section, subject: @subject1
      @discipline = @subject1.discipline
      load_test_section(@section1_1, @teacher1)

      @announcement1 = FactoryBot.create :announcement
      @announcement2 = FactoryBot.create :announcement
    end


    describe "as teacher" do
      before do
        sign_in(@teacher1)
        @home_page = "/teachers/#{@teacher1.id}"
      end
      it { has_valid_announcements(:teacher) }
    end

    describe "as school administrator" do
      before do
        @school_administrator = FactoryBot.create :school_administrator, school: @school1
        sign_in(@school_administrator)
        @home_page = "/school_administrators/#{@school_administrator.id}"
      end
      it { has_valid_announcements(:school_administrator) }
    end

    describe "as researcher" do
      before do
        @researcher = FactoryBot.create :researcher
        sign_in(@researcher)
        set_users_school(@school1)
        @home_page = "/researchers/#{@researcher.id}"
      end
      it { has_valid_announcements(:researcher) }
    end

    describe "as system administrator" do
      before do
        @system_administrator = FactoryBot.create :system_administrator
        sign_in(@system_administrator)
        set_users_school(@school1)
        @home_page = "/system_administrators/#{@system_administrator.id}"
      end
      it { has_valid_announcements(:system_administrator) }
    end

    describe "as student" do
      before do
        sign_in(@student)
        @home_page = "/students/#{@student.id}"
      end
      it { has_valid_announcements(:student) }
    end

    describe "as parent" do
      before do
        sign_in(@student.parent)
        @home_page = "/parents/#{@student.parent.id}"
      end
      it { has_valid_announcements(:parent) }
    end
  end

  ##################################################
  # test methods
  def has_valid_announcements(role)
    # has first announcement in header
    within("#announcements #announcement_#{@announcement1.id}") do
      page.should have_content(@announcement1.content)
      within(".announcement-alert .hide-alert") do
        page.should have_css("a[href='/announcements/#{@announcement1.id}/hide']")
      end
    end
    # hide first announcement
    page.should have_css("#announcements #announcement_#{@announcement1.id}")
    sleep 1
    within("#announcements #announcement_#{@announcement1.id} .announcement-alert .hide-alert") do
      # find 'id new annoucement then click HIDE'
      page.find("a[href='/announcements/#{@announcement1.id}/hide']").click
    end
    sleep 1
    # confirm javascript hid the first announcement
    page.should_not have_css("#announcements #announcement_#{@announcement1.id}")

    # hide second announcement
    page.should have_css("#announcements #announcement_#{@announcement2.id}")
    within("#announcements #announcement_#{@announcement2.id} .announcement-alert .hide-alert") do
      page.find("a[href='/announcements/#{@announcement2.id}/hide']").click
    end
    # confirm javascript hid the second announcement
    page.should_not have_css("#announcements #announcement_#{@announcement2.id}")

    # hide second announcement
    # within("#announcements #announcement_#{@announcement2.id} .announcement-alert .hide-alert") do
    #   page.find("a[href='/announcements/#{@announcement2.id}/hide']").click
    # end
    # confirm javascript hid the second announcement
    # page.should_not have_css("#announcements #announcement_#{@announcement2.id}")

    # confirm the highlighted announcements block is no longer showing
    page.should_not have_css("#announcements")

    # confirm first announcement is hidden on page refresh (by cookie)
    page.should_not have_css("#announcements #announcement_#{@announcement1.id}")

    # to do - confirm that only the first announcement is displayed to the user
    # note all alerts are hidden by css overflow-hidden, so the announcements are in the html

    # confirm only system administrators have the ability to maintain announcements
    if role == :system_administrator

      #############################################
      # confirm adding a new announcement is displayed in the alerts box
      page.should_not have_css("#announcements")
      find("#announcements-admin a[href='/announcements']").click
      assert_equal(current_path, '/announcements')
      sleep 1
      announcements = page.all("#announcements tr")
      announcements.length.should == 2

      # add an announcement
      find("a#show-add[data-url='/announcements/new.js']").click
      sleep 1
      fill_in("announcement_content", with: 'This is the first new Announcement!')
      find("#modal_popup form#new_announcement input[type='submit']").click

      # add another announcement
      find("a#show-add[data-url='/announcements/new.js']").click
      sleep 1
      fill_in("announcement_content", with: 'This is the second new Announcement!')
      find("#modal_popup form#new_announcement input[type='submit']").click

      # confirm at announcements page with the new announcement listed
      assert_equal(current_path, '/announcements')
      announcements = page.all("#announcements tr")

      # announcements.length.should == 4
      page.should have_css("#announcements #announcement_#{@announcement1.id}")
      page.should have_css("#announcements #announcement_#{@announcement2.id}")
      page.should have_css("#announcements #announcement_4")
      page.should have_css("#announcements #announcement_3")


      #############################################
      # confirm edit new announcement works properly

      # get id of new announcement from returned announcement elements and go to edit popup
      # announcement_id = announcements[3][:id].split('_')[1]
      within("#announcements tr#announcement_1") do
        find("a[data-target='#modal_popup']").click
      end

      # confirm on edit page
      page.should have_content('System Alert Message')
      sleep 1
      fill_in("announcement_content", with: 'This is a changed Announcement!')
      find("#modal_popup form#edit_announcement_#{@announcement1.id} input[type='submit']").click

      #remove changed announcement from list of announcements
      assert_equal(current_path, '/announcements')
      within("#announcements tr#announcement_1") do
        page.should have_content('This is a changed Announcement!')
      end

      # delete announcement
      within(announcements[2]) do
        find('a#delete-item').click
      end
      #click OK in javascript confirmation popup
      page.driver.browser.switch_to.alert.accept

      # confirm at announcements page without the new announcement listed
      assert_equal(current_path, '/announcements')
      announcements = page.all("#announcements tr")
      # announcements.length.should == 3
      page.should have_css("#announcements #announcement_#{@announcement1.id}")
      page.should have_css("#announcements #announcement_4")
      # deleted
      sleep 1
      page.should_not have_css("#announcements #announcement_#{@announcement2.id}")
      page.should have_css("#announcements #announcement_1")

      # confirm new announcement is no longer in the alert box at the top of the page
      within("#announcements") do
        page.should_not have_content('Announcement Content 2')
      end

      #############################################
      # confirm removing all announcements clears announcements maintenance icon in header

      # confirm announcements maintenance icon is shown
      page.should have_css("#announcements-admin a[href='/announcements']")

      #remove changed announcement from list of announcements
      assert_equal(current_path, '/announcements')
      within("#announcements") do
        within(announcements[1]) do
          find('a#delete-item').click
        end
      end
      # click OK in javascript confirmation popup
      page.driver.browser.switch_to.alert.accept
      within("#announcements") do
        within(announcements[0]) do
          find('a#delete-item').click
        end
      end
      page.driver.browser.switch_to.alert.accept

      find("#announcements #announcement_3 a[href='/announcements/3.js']").click
      # click OK in javascript confirmation popup
      page.driver.browser.switch_to.alert.accept

      # confirm announcements maintenance icon is no longer shown
      page.should_not have_css("#announcements-admin a[href='/announcements']")
    else
      # confirm this user cannot maintain system alerts
      page.should_not have_css("#announcements-admin")
      page.should_not have_css("a[href='/announcements']")
    end


  end # has_valid_announcements

end
