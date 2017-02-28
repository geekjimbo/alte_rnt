class CreateConvenioUbicacionEquipos < ActiveRecord::Migration
  def change
    create_table :convenio_ubicacion_equipos do |t|
      t.string :titulo_convenio
      t.date :fecha_vencimiento
      t.integer :numero_anexos
      t.boolean :adendas
      t.text :nota

      t.timestamps null: false
    end
    add_index :convenio_ubicacion_equipos, :titulo_convenio
    add_index :convenio_ubicacion_equipos, :fecha_vencimiento
    add_index :convenio_ubicacion_equipos, :adendas
  end
end
