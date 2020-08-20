class AddCurriculumCodeToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :curriculum_code, :string
  end
end
