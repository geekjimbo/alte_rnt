class ServicioHabilitado < ActiveRecord::Base
  belongs_to :sci_servicio, :foreign_key => "sciservicio_id"
  belongs_to :titulo_habilitante
end
