class MinimumGrades < ActiveRecord::Migration
  def up
    add_column :schools, :min_grade, :integer
  end

  def down
    remove_column :schools, :min_grade
  end
end
