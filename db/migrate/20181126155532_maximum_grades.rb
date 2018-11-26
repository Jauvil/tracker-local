class MaximumGrades < ActiveRecord::Migration
  def up
    add_column :schools, :max_grade, :integer
  end

  def down
    remove_column :schools, :max_grade
  end
end
