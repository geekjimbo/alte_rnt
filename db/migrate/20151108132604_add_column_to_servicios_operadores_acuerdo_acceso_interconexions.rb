class AddColumnToServiciosOperadoresAcuerdoAccesoInterconexions < ActiveRecord::Migration
  def change
      add_column :servicios_operadores_acuerdo_acceso_interconexions, :servicio, :string
  end
end
