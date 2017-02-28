class CreateOfertaInterconexionServicios < ActiveRecord::Migration
  def change
    create_table :oferta_interconexion_servicios do |t|
      t.references :oferta_interconexions,  index: true, column_name: :oferta_interconexions_id
      t.references :sci_servicios, index: true, column_name: :sci_servicios_id

      t.timestamps null: false
    end
  end
end
