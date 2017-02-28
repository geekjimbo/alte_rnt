class AddColumnToPreciosTarifas < ActiveRecord::Migration
  def change
    add_column :precios_tarifas, :tipo_precio_tarifa, :string
  end
end
