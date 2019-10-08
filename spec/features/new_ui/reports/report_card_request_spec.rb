require 'rails_helper'

##############################
# Updated for New UI 
# To Do: Move to spec/features/new_ui/ directory?
# ############################
shared_examples_for 'report card request form' do
  it do
    should have_selector 'form#new_report_card_request'
    should have_selector 'form select#report_card_request_grade_level'
    should have_selector "form .submit input[type='submit']"
  end
end

shared_examples_for 'cannot generate report card' do
  it { current_path.should_not == report_card_path }
end

describe "ReportCardRequest", js:true do

  subject { page }

  before (:each) do
    # @school = create :school
    @section = FactoryBot.create :section
      @subject = @section.subject
      @school = @section.school
      @school_administrator = create :school_administrator, school: @school, email: 'admin@example.com'
      @teacher = FactoryBot.create :teacher, school: @school
      @teacher_deact = FactoryBot.create :teacher, school: @school, active: false
      
      #A student and evidence section outcome ratings from the test 
      #section being loaded are used for  the test: 'Generate report card, 
      #grade level has student with multilingual comments'
      load_test_section(@section, @teacher)
  end




  describe 'Generate report card, grade level has student' do
    before do
      # we must clear the email queue first
      ActionMailer::Base.deliveries.clear
      @grade = 3
      @student = create :student, school: @school, grade_level: @grade
      sign_in @school_administrator
    end

    it 'should not generate report without grade level' do
      generate_report_card_for_grade false
      page.should have_css('.ui-error', text: "is a required field")
    end

    it 'cause delayed_job to send recieve and completed messages' do
      generate_report_card_for_grade @grade

      #kick off delayed jobs
      @successes, @failures = Delayed::Worker.new.work_off

      @successes.should == 2
      @failures.should  == 0
      ActionMailer::Base.deliveries.size.should == 2
      ActionMailer::Base.deliveries.first.subject.should == "Recieved: Grade #{@grade} Report Card Request"
      ActionMailer::Base.deliveries.last.subject.should  == "Completed: Grade #{@grade} Report Card Request"
      ActionMailer::Base.deliveries.last.attachments.count.should == 1
    end
  end

  #Currently tests for multiligual support for the following scripts: 
  #Arabic, Chinese (simplified), Extended Cyrilic, Extended Greek, Hebrew, 
  #Japanese, and Vietnamese
  #
  #Because Prawn did not have built-in support for Arabic script, report cards
  #with Arabic text in them were failing to be built. 
  #To Do: Consider refactoring the multiligual comment to a new file, so that 
  #test text for new languages to be supported can be added in one place across 
  #tests.
  describe 'Generate report card, grade level has student with multilingual comments' do
    before do
      # we must clear the email queue first
      ActionMailer::Base.deliveries.clear
      @grade = 4
      @student = create :student, school: @school, grade_level: @grade
      #give @student2 (loaded with the method: load_test_section)
      @student2.grade_level = @grade
      @student2.save

      multilingual_comment = "تطبيق القواعد النحوية
        红色火光映出锯齿形机翼的轮廓。
        З гучномовця над дверима скрипів записаний голос. 
        גלים התנפצו אל תוך הערב הכחול.
        Οι δύο φύσεις μου είχαν κοινές μνήμες
        そして夜空に最初の流れ星が現れた。
        Ging nói đu kia gào vào chic loa trên ca."
        
      #get EvidenceSectionOutcomeRatings for @student2
      student2_esor = EvidenceSectionOutcomeRating.where(:student_id => @student2.id)

      #give all of @student2's EvidenceSectionOutcomeRatings multilingual comments
      student2_esor.each do |esor|
        esor.comment = multilingual_comment
        esor.save
      end

      sign_in @school_administrator
    end

    it 'cause delayed_job to send recieve and completed messages' do
      generate_report_card_for_grade @grade

      #kick off delayed jobs
      @successes, @failures = Delayed::Worker.new.work_off

      @successes.should == 2
      @failures.should  == 0
      ActionMailer::Base.deliveries.size.should == 2
      ActionMailer::Base.deliveries.first.subject.should == "Recieved: Grade #{@grade} Report Card Request"
      ActionMailer::Base.deliveries.last.subject.should  == "Completed: Grade #{@grade} Report Card Request"
      ActionMailer::Base.deliveries.last.attachments.count.should == 1
    end
  end

  describe 'Generate report card, with no students in the selected grade' do
    before do
      sign_in(@school_administrator) 
      # we must clear the email queue first
      ActionMailer::Base.deliveries.clear

      # sign_in(@school_administrator, @school_administrator.password)
      # visit report_card_path
    end

    it 'cause delayed_job to send recieved and no student messages' do
      @grade = 5

            generate_report_card_for_grade @grade
      #kick off delayed jobs
      @successes, @failures = Delayed::Worker.new.work_off

      @successes.should == 2
      @failures.should  == 0
      ActionMailer::Base.deliveries.size.should == 2
      ActionMailer::Base.deliveries.first.subject.should == "Recieved: Grade #{@grade} Report Card Request"
      ActionMailer::Base.deliveries.last.subject.should  == "No Students Found: Grade #{@grade} Report Card Request"
      ActionMailer::Base.deliveries.last.attachments.count.should == 0
    end
  end

    describe 'when school administrator email is blank' do
     before do
       @school_administrator.email=''
       @school_administrator.save(validate: false)
       @grade = 3
     @student = create :student, school: @school, grade_level: @grade
       sign_in @school_administrator
       generate_report_card_for_grade @grade
     end
     it { should have_selector ".flash_alert", text: 'Request Submission error, Blank Email Exception' }
    end

  describe 'Student cannot generate report card' do
    before do
        @student = create :student, school: @school
      sign_in @student
      visit report_card_path
    end
    it_should_behave_like 'cannot generate report card'
    end

    describe 'Parent cannot generate report card' do
    before do
        @student = create :student, school: @school
        @parent = @student.parent
        @parent.password = 'password'
        @parent.password_confirmation = 'password'
        @parent.temporary_password = nil
        @parent.save!

      sign_in @parent
      visit report_card_path
    end
    it_should_behave_like 'cannot generate report card'
    end

    describe 'Counselor cannot generate report card' do
      before do
        @counselor = create :counselor, school: @school
        sign_in @counselor
        visit report_card_path
      end
      it_should_behave_like 'cannot generate report card'
    end

    describe 'Researcher cannot generate report card' do
    before do
      # We don't have a model for researcher
        @researcher = create :user, researcher:true
      sign_in(@researcher,@researcher.password)
      visit report_card_path
    end
    it_should_behave_like 'cannot generate report card'
    end
    ###########################################
    # test methods
    # #########################################
    
    def generate_report_card_for_grade grade
      visit new_generate_path
    page.find("form#new_generate fieldset", text: 'Select Report to generate', wait: 5).click
    page.find("ul#select2-results-2 li div", text: "Report Cards").click
    page.find("form#new_generate fieldset", text: "Select grade Level:").click if grade
    page.find("ul#select2-results-5 li div", text: "#{grade}").click if grade
    page.find("form#new_generate fieldset button", text: 'Generate').click
    #sleep 2
    end
end
