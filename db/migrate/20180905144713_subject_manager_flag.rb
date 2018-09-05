class SubjectManagerFlag < ActiveRecord::Migration
  def up
    add_column :server_configs, :allow_subject_mgr, :boolean, default: false
  end

  def down
    remove_column :server_configs, :allow_subject_mgr
  end
end
