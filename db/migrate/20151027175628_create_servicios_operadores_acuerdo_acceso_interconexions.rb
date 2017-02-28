class CreateServiciosOperadoresAcuerdoAccesoInterconexions < ActiveRecord::Migration
  def change
    create_table :servicios_operadores_acuerdo_acceso_interconexions do |t|
      t.decimal :precio_interconexion
      t.references :sci_servicios, index: {:name=>"idx_operadores_aai_servicios"}

      t.timestamps null: false
    end
  end
end
