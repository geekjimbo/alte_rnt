class CreateDetallePreciosTarifas < ActiveRecord::Migration
  def change
    create_table :detalle_precios_tarifas do |t|
      t.string :tipo_precio_tarifa
      t.string :servicio
      t.string :modalidad
      t.decimal :precio_tarifa
      t.date :fecha_vigencia
      t.string :estado
      t.references :precios_tarifas, index: {:name=>"idx_precios_tarifas_detalle"}

      t.timestamps null: false
    end
    add_index :detalle_precios_tarifas, :tipo_precio_tarifa, :name=>"idx_detalle_pyt_tipo"
    add_index :detalle_precios_tarifas, :servicio, :name=>"idx_detalle_pyt_servicio"
    add_index :detalle_precios_tarifas, :modalidad, :name=>"idx_detalle_pyt_modalidad"
    add_index :detalle_precios_tarifas, :estado, :name=>"idx_detalle_pyt_estado"
  end
end
