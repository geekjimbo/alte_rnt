class AddColumnToOfertaInterconexionServicios < ActiveRecord::Migration
  def change
      add_column :oferta_interconexion_servicios, :servicio, :string
  end
end
