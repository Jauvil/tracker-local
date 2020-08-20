class AddCurriculumTreeIdToSubjectOutcome < ActiveRecord::Migration[5.0]
  def change
    add_column :subject_outcomes, :curriculum_tree_id, :integer
  end
end
