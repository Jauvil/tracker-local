require 'rails_helper'

describe SubjectOutcomesController do
  before(:each) do
    create_sys_admin
    create_model_school
    create_subjects
    create_disciplines
    sign_in @system_administrator
  end

  describe "Get edit_curric_los" do
    before(:each) do
      build_params
      get :edit_curric_los, params: @edit_params
    end
    it "Should render edit_curric_los template" do
      expect(response).to render_template('edit_curric_los')
    end

    it "Should have a list of Tracker subjects to upload los from Curriculum App" do
      subjects = controller.instance_variable_get(:@subjects)
      expect(subjects.first).to eq @subject
    end

    it "Should have list of Curriculum versions to choose" do
      versions = controller.instance_variable_get(:@curriculum_versions)
      expect(versions.length).to be > 0
      expect(versions).not_to be_empty
    end
  end

  describe "Post update_curric_los" do

    context "No version change" do
      before(:each) do
        build_params
        post :update_curric_los, params: @invalid_upload_params
        @message = controller.instance_variable_get(:@version_errors).first
        @curriculum_subject = controller.instance_variable_get(:@curriculum_subjects_hash)
      end
      
      it "Should NOT upload LOs if the version is the same" do 
        expect(@message).to eq 'Mid year update is not available yet'
        expect(@curriculum_subject).to be_nil
      end
    end

    context "Version Change" do
      context "Upload LOs for 1 Subject" do 
        before(:each) do
          build_params
          post :update_curric_los, params: @single_upload_params
          @message = controller.instance_variable_get(:@version_errors).first
          @curriculum_subject = controller.instance_variable_get(:@curriculum_subjects_hash).first.second
          get_curriculum_subject_name
          @curriculum_LOs = controller.instance_variable_get(:@curriculum_los_hash).values
        end

        it "Should get matching Subject from Curriculum" do
          curriculum_subjects = controller.instance_variable_get(:@curriculum_subjects_hash).values
          expect(@subject.name).to eq @curriculum_subject_name
          expect(curriculum_subjects.length).to eq 1
        end

        it "Should upload Curriculum LOs for 1 Subject" do
          expect(@subject.subject_outcomes.length).to eq @curriculum_LOs.length
          curriculum_lo = @curriculum_LOs.first
          tracker_lo = @subject.subject_outcomes.first
          expect(tracker_lo.curriculum_tree_id).to eq curriculum_lo['tree_id']
        end
      end

      context "Upload LOs for All Subjects" do
        before(:each) do
          @old_tracker_LOs_count = SubjectOutcome.all.count
          build_params
          post :update_curric_los, params: @all_upload_params
          @message = controller.instance_variable_get(:@version_errors).first
          @curriculum_subjects = controller.instance_variable_get(:@curriculum_subjects_hash).values
          @curriculum_LOs = controller.instance_variable_get(:@curriculum_los_hash).values
        end

        it "Should get All Subjects for the specified curriculum code" do
          expect(@curriculum_subjects.length).to be > 1
        end

        it "Should upload Curriculum LOs for All Subjects" do
          expect(SubjectOutcome.all.count).to be > @old_tracker_LOs_count
        end
      end
    end

  end
  
end


def create_sys_admin
  @system_administrator = FactoryBot.create(:system_administrator)
  @system_administrator.update(
    email: 'ramin@21pstem.org'
  )
end

def create_model_school
  @model_school = FactoryBot.create :school_current_year, marking_periods:"2", name: 'Model School', acronym: 'MOD', min_grade: 9, max_grade: 12
  @model_school.update(
    curr_tree_type_id: 2, 
    curr_version_code: "v01",
    curriculum_code: "egstem",
    flags: "use_family_name,user_by_first,grade_in_subject_name,user_by_first_last,username_from_email"
  )
end

def create_subjects
  @subject = FactoryBot.create :subject
  @subject1 = FactoryBot.create :subject
  attributes = {
    name: "Biology 1",
    school_id: 1,
    curr_tree_type_id: 2, 
    curr_subject_code: "bio", 
    curr_subject_id: 15, 
    curr_grade_band_id: 14, 
    curr_grade_band_code: 1, 
    curr_grade_band_number: 1
  }
  @subject.update(attributes)
  @subject1.update(school_id: 1)
end

def create_disciplines
  @discipline = FactoryBot.create :discipline
  @discipline.update(name: 'Others')
end

def build_params
  @single_upload_params = {
    school_id: @model_school.id, 
    subject_id: @subject.id,
    version: 'v02'
  }
  @all_upload_params = {
    school_id: @model_school.id,
    version: 'v02'
  }
  @invalid_upload_params = {
    school_id: @model_school.id, 
    version: 'v01'
  }
  @edit_params = {
    school_id: @model_school.id
  }
end

def get_curriculum_subject_name
  subject_name = "#{@curriculum_subject['versioned_name']['en']}" 
  grade_code = ""
  @curriculum_subject['grade_bands'].each do |gb|
    if gb['id'] == @subject.curr_grade_band_id
      grade_code = gb['code']
    end
  end
  @curriculum_subject_name = subject_name + " " + grade_code
end
