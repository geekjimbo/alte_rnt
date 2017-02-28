class ServicioContratoAdhesion < ActiveRecord::Base
  belongs_to :contrato_adhesion, :foreign_key => "contrato_adhesions_id"
  belongs_to :sci_servicio, :foreign_key => "sci_servicios_id"
end
