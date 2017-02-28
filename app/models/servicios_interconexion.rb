class ServiciosInterconexion < ActiveRecord::Base
  belongs_to :acuerdo_acceso_interconexion, :foreign_key => :acuerdo_acceso_interconexions_id
  belongs_to :sci_servicios
end
