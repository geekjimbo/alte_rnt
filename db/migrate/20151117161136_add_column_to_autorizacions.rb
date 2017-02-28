class AddColumnToAutorizacions < ActiveRecord::Migration
  def change
    add_column :autorizacions, :fecha_vencimiento, :date
  end
end
