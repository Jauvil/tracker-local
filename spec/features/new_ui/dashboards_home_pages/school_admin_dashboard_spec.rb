# teacher_dashboard_spec.rb
require 'rails_helper'


describe "School Admin Dashboard", js:true do
  before (:each) do
    @school = FactoryBot.create :school_current_year, :arabic
    @teacher = FactoryBot.create :teacher, school: @school
    @subject = FactoryBot.create :subject, name: 'Subject 1', subject_manager: @teacher, school: @school
    @section = FactoryBot.create :section, subject: @subject
    @subj_math_3 = FactoryBot.create :subject, name: 'Math 3', subject_manager: @teacher, school: @school
    @subj_math_4 = FactoryBot.create :subject, name: 'Math 4', subject_manager: @teacher, school: @school
    @subj_math_5 = FactoryBot.create :subject, name: 'Math 5', subject_manager: @teacher, school: @school
    # consider determining order of subjects in dashboard, and then ensuring that subject 1 is there for testing appropriately
    # @subj_math_6 = FactoryBot.create :subject, name: 'Math 6', subject_manager: @teacher, school: @school
    # @subj_math_7 = FactoryBot.create :subject, name: 'Math 7', subject_manager: @teacher, school: @school
    # @subj_math_8 = FactoryBot.create :subject, name: 'Math 8', subject_manager: @teacher, school: @school
    # @subj_math_9 = FactoryBot.create :subject, name: 'Math 9', subject_manager: @teacher, school: @school
    # @subj_math_10 = FactoryBot.create :subject, name: 'Math 10', subject_manager: @teacher, school: @school
    # @subj_math_11 = FactoryBot.create :subject, name: 'Math 11', subject_manager: @teacher, school: @school
    # @subj_math_12 = FactoryBot.create :subject, name: 'Math 12', subject_manager: @teacher, school: @school
    @school_administrator = FactoryBot.create :school_administrator, school: @section.school
    load_test_section(@section, @teacher)

    @subject = @section.subject
  end

  describe "as teacher" do
    before do
      sign_in(@teacher)
    end
    it { cannot_see_school_admin_dashboard }
  end

  describe "as school administrator" do
    before do
      sign_in(@school_administrator)
    end
    it { school_admin_dashboard_is_valid }
  end

  describe "as researcher" do
    before do
      @researcher = FactoryBot.create :researcher
      sign_in(@researcher)
      set_users_school(@section.school)
    end
    it { school_admin_dashboard_is_valid }
  end

  describe "as system administrator" do
    before do
      @system_administrator = FactoryBot.create :system_administrator
      sign_in(@system_administrator)
      set_users_school(@section.school)
    end
    it { school_admin_dashboard_is_valid }
  end

  describe "as student" do
    before do
      sign_in(@student)
    end
    it { cannot_see_school_admin_dashboard }
  end

  describe "as parent" do
    before do
      sign_in(@student.parent)
    end
    it { cannot_see_school_admin_dashboard }
  end

  ##################################################
  # test methods

  def cannot_see_school_admin_dashboard
    visit school_administrator_path(@school_administrator.id)
    assert_not_equal("/school_administrators/#{@school_administrator.id}", current_path)
  end

  def school_admin_dashboard_is_valid
    visit school_administrator_path(@school_administrator.id)
    assert_equal("/school_administrators/#{@school_administrator.id}", current_path)

    # Note overall lo counts should == prof bar counts for each color
    within("#overall") do
      page.should have_content('9 - High Performance')
      page.should have_content('9 - Proficient')
      page.should have_content('9 - Not Yet Proficient')
      page.should have_content('9 - Unrated')
    end


    within("#proficiency") do
      page.should have_css('div.high-rating-bar', text: '9')
      page.should have_css('div.prof-rating-bar', text: '9')
      page.should have_css('div.nyp-rating-bar', text: '9')
      page.should have_css('div.unrated-rating-bar', text: '9')
      # Test that all subjects are listed in the "Learning Outcomes Covered" table,
      # and test that the link to the Subject matches the name of the subject displayed
      # in the table.
      subjects_list = [@subject, @subj_math_3, @subj_math_4, @subj_math_5]
      subjects_list.each do |s|
        page.should have_css("tbody td.subject-link a[href='/subjects/#{s.id}']")
        within("tbody td.subject-link a[href='/subjects/#{s.id}']") do
          page.should have_content("#{s.name}")
        end
      end

    end

    # make sure learning outcomes covered match
    within("#learning") do
      page.should have_content("4 out of 4")
      # make sure first entry is Subject 1
      subject_nodes = all('tbody td.subject-link a').map(&:text)
      subject_nodes[0].should == @subject.name
    end

    #  validate links on page
    find("#prof-subj-#{@subject.id}")[:href].should have_content("/subjects/#{@subject.id}")
    find("#learning-subj-#{@subject.id}")[:href].should have_content("/subjects/#{@subject.id}")

    # page.find("tr a[href='/sections/#{@section.id}/class_dashboard']").click
    # assert_equal("/sections/#{@section.id}/class_dashboard", current_path)
  end

end
