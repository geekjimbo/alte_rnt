class OfertaInterconexionServicio < ActiveRecord::Base
  belongs_to :oferta_interconexion, :foreign_key => "oferta_interconexions_id"
  belongs_to :sci_servicio, :foreign_key => "sci_servicios_id"

  validates :precio, presence: true
end
