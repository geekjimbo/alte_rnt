class AddProfileToAsiento < ActiveRecord::Migration
  def change
    add_column :asientos, :acto_id, :integer
    add_index :asientos, :acto_id
    add_column :asientos, :acto_type, :string
    add_index :asientos, :acto_type
  end
end
