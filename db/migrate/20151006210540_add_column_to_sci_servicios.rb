class AddColumnToSciServicios < ActiveRecord::Migration
  def change
    add_column :sci_servicios, :nota, :string
  end
end
