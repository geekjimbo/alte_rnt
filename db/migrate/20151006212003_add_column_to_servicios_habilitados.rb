class AddColumnToServiciosHabilitados < ActiveRecord::Migration
  def change
    add_column :servicio_habilitados, :nota, :string
  end
end
