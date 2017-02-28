class CreateAddOperadoresToOperadoresConvenioUbicacionEquipos < ActiveRecord::Migration
  def change
    add_reference :operadores_convenio_ubicacion_equipos, :operador_regulados, index: {:name=>"idx_convenio_ubic_equipos_operadores"}
  end
end
