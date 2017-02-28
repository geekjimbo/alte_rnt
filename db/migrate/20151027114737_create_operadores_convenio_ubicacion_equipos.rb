class CreateOperadoresConvenioUbicacionEquipos < ActiveRecord::Migration
  def change
    create_table :operadores_convenio_ubicacion_equipos do |t|
      t.references :convenio_ubicacion_equipos, index: {:name => "idx_operadores_convenio_ubicacion_equipos"}

      t.timestamps null: false
    end
  end
end
