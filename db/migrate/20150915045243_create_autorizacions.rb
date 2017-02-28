class CreateAutorizacions < ActiveRecord::Migration
  def change
    create_table :autorizacions do |t|
      t.string :numero_publicacion_gaceta
      t.string :fecha_publicacion_gaceta
      t.string :tipo_red

      t.timestamps null: false
    end
    add_index :autorizacions, :numero_publicacion_gaceta
    add_index :autorizacions, :fecha_publicacion_gaceta
    add_index :autorizacions, :tipo_red
  end
end
