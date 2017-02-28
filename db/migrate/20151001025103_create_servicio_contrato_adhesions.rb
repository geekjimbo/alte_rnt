class CreateServicioContratoAdhesions < ActiveRecord::Migration
  def change
    create_table :servicio_contrato_adhesions do |t|
      t.references :contrato_adhesions, column_name: :contrato_adhesions_id, index: true
      t.references :sci_servicios, column_name: :sci_servicios_id, index: true

      t.timestamps null: false
    end
  end
end