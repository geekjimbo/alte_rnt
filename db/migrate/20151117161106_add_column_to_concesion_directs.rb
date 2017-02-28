class AddColumnToConcesionDirects < ActiveRecord::Migration
  def change
    add_column :concesion_directs, :fecha_vencimiento, :date
  end
end
