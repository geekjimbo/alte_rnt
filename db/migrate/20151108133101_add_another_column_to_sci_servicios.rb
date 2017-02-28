class AddAnotherColumnToSciServicios < ActiveRecord::Migration
  def change
      add_column :sci_servicios, :servicio, :string
  end
end
