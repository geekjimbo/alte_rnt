class OperadoresResolucionUbicacionEquipo < ActiveRecord::Base
  belongs_to :operador_regulados, :foreign_key => "operador_regulados_id"
  belongs_to :resolucion_ubicacion_equipos, :foreign_key=>"resolucion_ubicacion_equipos_id"
end
