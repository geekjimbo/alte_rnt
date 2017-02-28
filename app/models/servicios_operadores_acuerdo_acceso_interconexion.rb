class ServiciosOperadoresAcuerdoAccesoInterconexion < ActiveRecord::Base
  belongs_to :operadores_acuerdo_acceso_interconexions, :foreign_key=>"operadores_acuerdo_acceso_interconexions_id"
  belongs_to :sci_servicios, :foreign_key=>"sci_servicios_id"
end
