class CreateConsecionPublicas < ActiveRecord::Migration
  def change
    create_table :consecion_publicas do |t|
      t.string :tipo_red
      t.date :fecha_publicacion
      t.string :numero_publicacion
      t.string :contrato_concesion
      t.date :fecha_emision
      t.string :numero_notificacion_refrendo

      t.timestamps null: false
    end
    add_index :consecion_publicas, :tipo_red
    add_index :consecion_publicas, :fecha_publicacion
    add_index :consecion_publicas, :numero_publicacion
    add_index :consecion_publicas, :fecha_emision
    add_index :consecion_publicas, :numero_notificacion_refrendo
  end
end
