class AddColumnToServiciosInterconexions < ActiveRecord::Migration
  def change
      add_column :servicios_interconexions, :servicio, :string
  end
end
