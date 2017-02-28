class AddColumnToFrecuenciaEspectro < ActiveRecord::Migration
  def change
    add_column :frecuencia_espectros, :desde, :decimal
    add_column :frecuencia_espectros, :hasta, :decimal
    add_column :frecuencia_espectros, :tx_desde, :decimal
    add_column :frecuencia_espectros, :tx_hasta, :decimal
    add_column :frecuencia_espectros, :rx_desde, :decimal
    add_column :frecuencia_espectros, :rx_hasta, :decimal
  end
end
