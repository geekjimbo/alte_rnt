class AddIndexToConsecutivos < ActiveRecord::Migration
  def change
  	add_column :consecutivos, :contador_as, :integer
    add_column :consecutivos, :contador_md, :integer
    add_index :consecutivos, :contador_md
    add_index :consecutivos, :contador_as
  end
end
