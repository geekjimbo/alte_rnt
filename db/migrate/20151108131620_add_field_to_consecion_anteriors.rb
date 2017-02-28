class AddFieldToConsecionAnteriors < ActiveRecord::Migration
  def change
      add_column :consecion_anteriors, :numero_adecuacion_poder_ejecutivo, :string
  end
end
