class CreateResolucionUbicacionEquipos < ActiveRecord::Migration
  def change
    create_table :resolucion_ubicacion_equipos do |t|
      t.date :fecha_vigencia
      t.text :nota

      t.timestamps null: false
    end
    add_index :resolucion_ubicacion_equipos, :fecha_vigencia
  end
end
