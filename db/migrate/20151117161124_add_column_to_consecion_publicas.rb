class AddColumnToConsecionPublicas < ActiveRecord::Migration
  def change
    add_column :consecion_publicas, :fecha_vencimiento, :date
  end
end
