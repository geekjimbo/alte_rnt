class AddColumnToServicioHabilitados < ActiveRecord::Migration
  def change
      add_column :servicio_habilitados, :servicio, :string
  end
end
