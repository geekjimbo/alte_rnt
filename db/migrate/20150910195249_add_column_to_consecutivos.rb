class AddColumnToConsecutivos < ActiveRecord::Migration
  def change
    add_column :consecutivos, :md, :boolean, :default => false
    add_column :consecutivos, :as, :boolean, :default => false
  end
end
