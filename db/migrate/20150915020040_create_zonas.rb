class CreateZonas < ActiveRecord::Migration
  def change
    create_table :zonas do |t|
      t.string :tipo_zona
      t.string :descripcion_zona
      t.text :nota
      t.belongs_to :frecuenciaespectro, index: true, foreign_key: false

      t.timestamps null: false
    end
    add_index :zonas, :tipo_zona
  end
end
