class CreateOfertaInterconexions < ActiveRecord::Migration
  def change
    create_table :oferta_interconexions do |t|
      t.string :numero_publicacion_gaceta
      t.date :fecha_publicacion_gaceta
      t.text :contenido_oferta
      t.date :fecha_vencimiento

      t.timestamps null: false
    end
    add_index :oferta_interconexions, :numero_publicacion_gaceta
    add_index :oferta_interconexions, :fecha_publicacion_gaceta
    add_index :oferta_interconexions, :fecha_vencimiento
  end
end
