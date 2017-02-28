class AddOperadoresToServiciosOperadoresAcuerdoAccesoInterconexion < ActiveRecord::Migration
  def change
    add_reference :servicios_operadores_acuerdo_acceso_interconexions, :operadores_acuerdo_acceso_interconexions, index: {:name=>"idx_servicios_op_aai"}
  end
end
