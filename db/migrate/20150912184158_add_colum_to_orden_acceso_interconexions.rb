class AddColumToOrdenAccesoInterconexions < ActiveRecord::Migration
  def change
    add_column :orden_acceso_interconexions, :fecha_vigencia, :string
    add_index :orden_acceso_interconexions, :fecha_vigencia
  end
end
