class OperadoresConvenioUbicacionEquipo < ActiveRecord::Base
  belongs_to :convenio_ubicacion_equipos, :foreign_key => "convenio_ubicacion_equipos_id"
  belongs_to :operador_regulados, :foreign_key => "operador_regulados_id"
end
