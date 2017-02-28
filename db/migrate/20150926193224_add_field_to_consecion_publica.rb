class AddFieldToConsecionPublica < ActiveRecord::Migration
  def change
    add_column :consecion_publicas, :fecha_notificacion_refrendo, :date
  end
end
