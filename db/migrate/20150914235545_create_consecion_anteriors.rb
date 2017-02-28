class CreateConsecionAnteriors < ActiveRecord::Migration
  def change
    create_table :consecion_anteriors do |t|
      t.string :adecuacion_poder_ejecutivo

      t.timestamps null: false
    end
  end
end
