class AddFieldToOfertaInterconexionServicio < ActiveRecord::Migration
  def change
    add_column :oferta_interconexion_servicios, :precio, :decimal
  end
end
