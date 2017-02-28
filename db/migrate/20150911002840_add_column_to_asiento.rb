class AddColumnToAsiento < ActiveRecord::Migration
  def change
    add_column :asientos, :vigencia, :integer
    add_index :asientos, :vigencia
  end
end
