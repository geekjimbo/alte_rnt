class RemoveColumFromOrdenAccesoInterconexions < ActiveRecord::Migration
  def change
    remove_column :orden_acceso_interconexions, :vigencia, :string
  end
end
