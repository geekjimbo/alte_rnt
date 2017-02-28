class AddFieldToZona < ActiveRecord::Migration
  def change
    add_column :zonas, :provincia, :string
    add_column :zonas, :canton, :string
    add_column :zonas, :distrito, :string
  end
end
