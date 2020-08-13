class AddCurriculumFieldsToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :curr_tree_type_id, :integer
    add_column :schools, :curr_version_code, :string
  end
end
