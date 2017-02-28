class AddColumnToServicioContratoAdhesions < ActiveRecord::Migration
  def change
      add_column :servicio_contrato_adhesions, :servicio, :string
  end
end
