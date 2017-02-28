class AddFieldToArbitro < ActiveRecord::Migration
  def change
    add_column :arbitros, :fecha_vencimiento, :date
  end
end
