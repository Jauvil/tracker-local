class AddCurriculumFieldsToSubject < ActiveRecord::Migration[5.0]
  def change
    add_column :subjects, :curr_tree_type_id, :integer
    add_column :subjects, :curr_subject_code, :string
    add_column :subjects, :curr_subject_id, :integer
    add_column :subjects, :curr_grade_band_id, :integer
    add_column :subjects, :curr_grade_band_code, :integer 
    add_column :subjects, :curr_grade_band_number, :integer 
  end
end
