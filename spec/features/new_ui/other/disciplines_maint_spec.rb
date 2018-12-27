# disciplines_maint_spec.rb
require 'spec_helper'


describe "Disciplines Maintenance", js:true do
  before (:each) do

    create_and_load_arabic_model_school

    # @school
    @school = FactoryBot.create :school_current_year, :arabic
    @teacher = FactoryBot.create :teacher, school: @school
    @subject = FactoryBot.create :subject, school: @school, subject_manager: @teacher
    @disciplines << @subject.discipline
    @section = FactoryBot.create :section, subject: @subject
    @discipline = @subject.discipline
    load_test_section(@section, @teacher)

    @discipline_ids = @disciplines.map{ |d| d.id}

    @subject2 = FactoryBot.create :subject, school: @school, discipline: @discipline, name: 'Astrophysics 1'
    @subject3 = FactoryBot.create :subject, school: @school, discipline: @discipline, name: 'Astrophysics 2'
    @subject4 = FactoryBot.create :subject, school: @school, discipline: @discipline, name: 'Astrophysics 3'

  end

  describe "as teacher" do
    before do
      sign_in(@teacher)
      @home_page = "/teachers/#{@teacher.id}"
    end
    it { cannot_see_discipline_maint }
  end

  describe "as school administrator" do
    before do
      @school_administrator = FactoryBot.create :school_administrator, school: @school
      sign_in(@school_administrator)
      @home_page = "/school_administrators/#{@school_administrator.id}"
    end
    it { cannot_see_discipline_maint }
  end

  describe "as researcher" do
    before do
      @researcher = FactoryBot.create :researcher
      sign_in(@researcher)
      # set_users_school(@school)
      @home_page = "/researchers/#{@researcher.id}"
    end
    it { can_see_discipline_maint }
  end

  describe "as system administrator" do
    before do
      @system_administrator = FactoryBot.create :system_administrator
      sign_in(@system_administrator)
      # set_users_school(@school)
      @home_page = "/system_administrators/#{@system_administrator.id}"
    end
    it { can_do_discipline_maint }
  end

  describe "as student" do
    before do
      sign_in(@student)
      @home_page = "/students/#{@student.id}"
    end
    it { cannot_see_discipline_maint }
  end

  describe "as parent" do
    before do
      sign_in(@student.parent)
      @home_page = "/parents/#{@student.parent.id}"
    end
    it { cannot_see_discipline_maint }
  end

  ##################################################
  # test methods

  def cannot_see_discipline_maint
    # should not have a active toolkit item for System Maint.
    page.should_not have_css("#side-sys-maint")
    page.should_not have_css("a[href='/system_administrators/system_maintenance']")
    # try to go directly to page
    visit system_maintenance_system_administrators_path
    assert_equal(@home_page, current_path)

    # evidence types listing should not have links to new or edit
    visit disciplines_path
    assert_equal(@home_page, current_path)
    page.should_not have_css("a[href='/disciplines/#{@discipline_ids[0]}/edit']")
    page.should_not have_css("a[data-url='/disciplines/#{@discipline_ids[0]}/edit.js']")
    page.should_not have_css("a[href='/disciplines/new']")
    page.should_not have_css("a[data-url='/disciplines/new.js']")

    # should not be able to directly maintain evidence types
    visit edit_discipline_path(@discipline_ids[0])
    assert_equal(@home_page, current_path)
    visit new_discipline_path
    assert_equal(@home_page, current_path)

  end # cannot_see_evid_type_maint

  def can_see_discipline_maint
    # should not have a active toolkit item for System Maint.
    page.should_not have_css("#side-sys-maint")
    page.should_not have_css("a[href='/system_administrators/system_maintenance']")
    # try to go directly to page
    visit system_maintenance_system_administrators_path
    assert_equal(@home_page, current_path)

    # evidence types listing should not have links to new or edit
    visit disciplines_path
    assert_equal(disciplines_path, current_path)
    page.should_not have_css("a[href='/disciplines/#{@discipline_ids[0]}/edit']")
    page.should_not have_css("a[data-url='/disciplines/#{@discipline_ids[0]}/edit.js']")
    page.should_not have_css("a[href='/disciplines/new']")
    page.should_not have_css("a[data-url='/disciplines/new.js']")

    # should not be able to directly maintain evidence types
    visit edit_discipline_path(@discipline_ids[0])
    assert_equal(@home_page, current_path)
    visit new_discipline_path
    assert_equal(@home_page, current_path)

  end # can_see_evid_type_maint

  def can_do_discipline_maint
    # this is only seen by a system administrator, so landing page should be the sys admin home page


    ###########################
    # Disciplines Listing page tests

    # go to system maintenance page directly
    visit system_maintenance_system_administrators_path
    assert_not_equal(@home_page, current_path)
    assert_equal(system_maintenance_system_administrators_path, current_path)

    # click the discipline maintenance link
    page.find('#sys-admin-links #disciplines a').click
    assert_equal('/disciplines', current_path)

    # page should list the current disciplines
    initial_count = page.all('tr.discipline-item').count

    assert_equal( 7, initial_count )
    assert_equal( initial_count, @discipline_ids.length )


    ###########################
    # Show Discipline test

    page.find("#d_#{@discipline.id} a[href='/disciplines/#{@discipline.id}']").click
    assert_equal("/disciplines/#{@discipline.id}", current_path)
    within("#discipline") do
      page.should have_css("a#show-to-list[href='/disciplines']")
      page.should have_css("a#show-to-edit[href='/disciplines/#{@discipline.id}/edit']")
      within("#school_#{@school.acronym}") do
        page.should have_content(@subject.name)
        page.should have_content(@subject2.name)
        page.should have_content(@subject3.name)
        page.should have_content(@subject4.name)
      end
    end

    ###########################
    # Add Discipline tests

    visit disciplines_path
    assert_equal('/disciplines', current_path)

    # Add a discipline type with no description should return error
    page.find('a#show-disc-to-add').click
    page.should have_css('#modal-body h2', text: 'Maintain Disciplines')
    page.find("#modal-body form#new_discipline input[value='Save']").click
    page.should have_css('#modal-body h2', text: 'Maintain Disciplines')
    page.should have_css("#modal-body form#new_discipline fieldset#discipline_name span.ui-error")

    # edit returned error form to add new discipline
    fill_in("discipline[name]", with: 'Mathematics')
    page.find("#modal-body form#new_discipline input[value='Save']").click

    # Confirm new discipline is in displayed listing
    assert_equal('/disciplines', current_path)
    within('#page-content table tbody') do
      page.should have_content('Mathematics')
    end

    # Confirm add a discipline type top row button works (and cancel add works)
    page.find('a#add-discipline').click
    page.should have_css('#modal-body h2', text: 'Maintain Disciplines')
    page.find("#modal-body form#new_discipline a[href='/disciplines']").click
    assert_equal('/disciplines', current_path)


    ##############################
    # edit the newly created discipline (not one created by testing factory)

    # get the newly added discipline id by finding the one not in the original list
    updated_disciplines = page.all("tr.discipline-item")
    updated_disciplines.length.should == initial_count + 1

    new_d_id = ''
    updated_disciplines.each do |d|
      d_id_s = d[:id].split('_')[1]
      d_id = Integer(d_id_s) rescue 0
      if !@discipline_ids.include?(d_id)
        # this id is not found in original list of ids - this is the id for the new one
        new_d_id = d_id
        break
      end
    end
    assert_not_equal('', new_d_id)

    # click the edit button for the newly created discipline
    within("tr#d_#{new_d_id}") do
      find("a[data-url='/disciplines/#{new_d_id}/edit.js']").click
    end
    page.should have_css('#modal-body h2', text: 'Maintain Disciplines')

    # blank out evidence name to ensure blanks are not allowed
    fill_in("discipline[name]", with: '')
    page.find("#modal-body form#edit_discipline_#{new_d_id} input[value='Save']").click
    page.should have_css('#modal-body h2', text: 'Maintain Disciplines')
    page.should have_css("#modal-body form#edit_discipline_#{new_d_id} fieldset#discipline_name span.ui-error")

    # put in a different name for the evidence type
    fill_in("discipline[name]", with: 'Science')
    page.find("#modal-body form#edit_discipline_#{new_d_id} input[value='Save']").click

    # Confirm updated evidence type is in displayed listing
    assert_equal('/disciplines', current_path)
    within('#page-content table tbody') do
      page.should_not have_content('Mathematics')
      page.should have_content('Science')
    end


    # to do - add deactivate option for evidence types (requires database change and many tests)

  end # can_do_discipline_maint

end
