class CreatePreciosTarifas < ActiveRecord::Migration
  def change
    create_table :precios_tarifas do |t|
      t.date :fecha_publicacion_gaceta
      t.string :numero_publicacion_gaceta

      t.timestamps null: false
    end
    add_index :precios_tarifas, :fecha_publicacion_gaceta, :name => "idx_preciostarifas_fecha_gaceta"
    add_index :precios_tarifas, :numero_publicacion_gaceta, :name=>"idx_preciostarifas_numero_gaceta"
  end
end
