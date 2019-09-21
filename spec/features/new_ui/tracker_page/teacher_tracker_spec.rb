# teacher_tracker_spec.rb
require 'rails_helper'


describe "Teacher Tracker", js:true do
  before (:each) do
    @section = FactoryBot.create :section
    @teacher = FactoryBot.create :teacher, school: @section.school
    #for method def, see: load_section_helper.rb
    load_test_section(@section, @teacher)
    # add second section to be able to copy evidence to
    @secondSection = FactoryBot.create :section, subject: @section.subject, school_year: @section.school.school_year
    @seondTeachingAssignment = FactoryBot.create :teaching_assignment, teacher: @teacher, section: @secondSection
    @thirdSection = FactoryBot.create :section, subject: @section.subject, school_year: @section.school.school_year
  end
#to do: teacher, school administrator and system administrator should be able to rate a single LO
  describe "as teacher" do
    before do
      sign_in(@teacher)
    end
    it { teacher_tracker_is_valid(true) }
  end

  describe "as school administrator" do
    before do
      @school_administrator = FactoryBot.create :school_administrator, school: @section.school
      sign_in(@school_administrator)
    end
    it { teacher_tracker_is_valid(true) }
  end

  describe "as researcher" do
    before do
      @researcher = FactoryBot.create :researcher
      sign_in(@researcher)
      set_users_school(@section.school)
    end
    it { teacher_tracker_is_valid(false) }
  end

  describe "as system administrator" do
    before do
      @system_administrator = FactoryBot.create :system_administrator
      sign_in(@system_administrator)
      set_users_school(@section.school)
    end
    it { teacher_tracker_is_valid(true) }
  end

  describe "as student" do
    before do
      sign_in(@student)
    end
    it { cannot_see_teacher_tracker }
  end

  describe "as parent" do
    before do
      sign_in(@student.parent)
    end
    it { cannot_see_teacher_tracker }
  end

  ##################################################
  # test methods

  def cannot_see_teacher_tracker
    visit section_path(@section.id)
    assert_not_equal("/sections/#{@section.id}", current_path)
  end

  def teacher_tracker_is_valid(editable)
    visit section_path(@section.id)
    assert_equal("/sections/#{@section.id}", current_path)
    # On Teacher Tracker Page
    page.should have_content("All Learning Outcomes")
    within("table[data-section-id='#{@section.id}']") do
      page.should have_content("#{@subject_outcomes.values[0].name}")
      page.should have_css('tbody.tbody-header')
      page.should have_css("*[data-so-id='#{@subject_outcomes.values[0].id}']")
      page.should have_css("tbody.tbody-header[data-so-id='#{@subject_outcomes.values[0].id}']")
      page.should have_css("tbody.tbody-header[data-so-id='#{@subject_outcomes.values[0].id}'].tbody-open")
      @section_outcomes.each do |so|
        # page.should have_css('tbody.tbody-section[data-so-id="#{so.id}"]')
        # within('tbody.tbody-section[data-so-id="#{so.id}"]') do
        within("tbody.tbody-section[data-so-id='#{@subject_outcomes.values[0].id}']") do
          page.should have_content("#{@evidences.values[0].name}")
          page.should have_content("#{@evidences.values[1].name}")
          page.should have_content("#{@evidences.values[2].name}")
          page.should have_content("#{@evidences.values[3].name}")
          page.should have_content("#{@evidences.values[4].name}")
          page.should have_content("#{@evidences.values[5].name}")
        end
      end
    end
    # Collapse all Learning Outcomes (to hide evidences)
    find("div#collapse-all-los-button").click
    page.should have_content("#{@subject_outcomes.values[0].name}")
    page.should have_css('tbody.tbody-header')
    page.should have_css("*[data-so-id='#{@subject_outcomes.values[0].id}']")
    page.should have_css("tbody.tbody-header[data-so-id='#{@subject_outcomes.values[0].id}']")
    page.should_not have_css("tbody.tbody-header[data-so-id='#{@subject_outcomes.values[0].id}'].tbody-open")

    # Test Adding a Piece of Evidence
    if editable
      page.should have_content("All Learning Outcomes")
      test_ratings = [["li.blue", "H"], ["li.green", "P"], ["li.red", "N"], ["li.unrated", "U"]]
      test_ratings.each do |r|
        #Try to edit single section outcome rating on the tracker page for 
        #a student with existing SectionOutcomeRatings
        can_rate_single_LO(@student, r[0], r[1])
        #Try to edit single section outcome rating on the tracker page for 
        #a student without existing SectionOutcomeRatings
        can_rate_single_LO(@student_new, r[0], r[1])
      end
      # Click on Toolkit to add a new piece of evidence
      page.should have_css("li#side-add-evid a[href='/sections/#{@section.id}/new_evidence']")
      find("li#side-add-evid a[href='/sections/#{@section.id}/new_evidence']").click
      # Add Evidence page
      assert_equal("/sections/#{@section.id}/new_evidence", current_path)
      page.should have_content('Add Evidence')
      page.fill_in 'evidence_name', :with => 'Add and Notify'
      page.fill_in 'evidence_description', :with => 'Add and notify student by email.'
      find("#evidence_evidence_type_id option[value='7']").select_option
      page.execute_script("$('#evidence_assignment_date_evid-date').val('2015-09-01')")
      find("input#send_email").should_not be_checked
      find("input#send_email").click
      find("input#send_email").should be_checked
      # add evidence to one learning outcome
      # find("#evid-current-los .block-title i").click
      find("span.add_lo_to_evid[data-so-id='#{@section_outcomes.first[1].id}'] i").click
      # find("#evid-other-los .block-title i").click

      # clone of new attachment element template.
      execute_script("$('#evid-add-attachments li').clone().addClass('test-attachment-elem').appendTo('#evid-attachments-ul')")
      execute_script("$('.test-attachment-elem').first().find('.attach_remove').attr('name', $('.test-attachment-elem').first().find('.attach_remove').attr('name').replace('xxseqxx', 0))")
      execute_script("$('.test-attachment-elem').first().find('.attach_item').attr('name', $('.test-attachment-elem').first().find('.attach_item').attr('name').replace('xxseqxx', 0))")

      attach_file('evidence[evidence_attachments_attributes][0][attachment]', File.join(Rails.root, '/spec/fixtures/files/StaffDataUpload.csv'))
      within('#evid-attachments-ul') do
        page.find('.attach_name', match: :first).set("test file")
      end
      
      page.find('#show-hyper-to-add').click
      page.find('#evid-hyperlinks-ul .attach_item', match: :first).set('www.google.com')
      page.find('#evid-hyperlinks-ul .attach_name', match: :first).set('test link')

      page.find(".sectioned-list input[name='sections[]'][value='2']", wait: 5).set(true)
      # Save Button not working
      find('button', text: 'Save').click
      sleep 10
      wait_for_ajax
      # ToDo 'Add Evidence' link is disabled
      # pending "'ADD EVIDENCE' link is disabled" do
      find("div#expand-all-los-button").click
      # end
      within("tbody.tbody-section[data-so-id='#{@section_outcomes.first[1].id}']") do
        page.should have_content('Add and Notify')
      end
    else
      page.should have_css("#side-add-evid a[href='/sections/#{@section.id}/new_evidence'].disabled")
    end

    # Test Bulk Rate Evidence page
    if editable
      puts ("section_outcomes/#{@section_outcomes.first[1].id}")
      page.find("#tracker-table-container table[data-section-id='#{@section.id}'] a[href='/section_outcomes/#{@section_outcomes.first[1].id}']", wait: 5).click
      # got to bulk rating page
      assert_equal("/section_outcomes/#{@section_outcomes.first[1].id}", current_path)
      # To Do : confirm bulk rating works correctly
    else
      # To Do: Prevent Researchers from seeing bulk rate LO page?
      # page.should have_css("#tracker-table-container table[data-section-id='#{@section.id}'] a[href='/section_outcomes/#{@section_outcomes.first[1].id}'].disabled")
    end


    # # to do - edit evidence note from deleted non-working edit_evidence_spec that was only for teachers
    # page.find("#tracker-table-container tbody.tbody-section[data-so-id='1'] tr[data-eso-id='7'] a.evidence-edit").click
    # page.should have_selector('.modal-header h3', text: 'Edit Evidence')
    # # fill in form
    # check('#evidence_reassessment')


    # todo - validate links on page
    # page.find("tr a[href='/sections/#{@section.id}/class_dashboard']").click
    # assert_equal("/sections/#{@section.id}/class_dashboard", current_path)
  end

  #Try to rate single learning outcomes on the tracker page for 
  #the student passed in as a param
  def can_rate_single_LO(student, rating_selector, rating_content)
    #Save ratings for student with existing SectionOutcomeRating 
    page.should have_css('td.s_o_r')
    page.first("td.s_o_r[data-student-id='#{student.id}']").click
    #try giving the student a High Performance rating, and saving
    page.find("div#popup-rate-single-lo #{rating_selector}").click
    page.find("button#save-single-lo").click
    page.first("td.s_o_r[data-student-id='#{student.id}']").should have_content(rating_content)
  end

end
