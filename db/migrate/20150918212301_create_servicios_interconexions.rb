class CreateServiciosInterconexions < ActiveRecord::Migration
  def change
    create_table :servicios_interconexions do |t|
      t.decimal :precio_interconexion
      #t.references :acuerdo_acceso_interconexions, index: {:name => "idx_acuerdos"}, foreign_key: true
      #t.references :sci_servicios, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
