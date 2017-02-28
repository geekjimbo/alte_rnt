class AddColumnToDetallePreciosTarifas < ActiveRecord::Migration
  def change
    add_reference :detalle_precios_tarifas, :sci_servicios, index: {:name=>"idx_detalle_pyt_servicios"}
  end
end
