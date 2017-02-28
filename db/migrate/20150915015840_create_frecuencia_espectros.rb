class CreateFrecuenciaEspectros < ActiveRecord::Migration
  def change
    create_table :frecuencia_espectros do |t|
      t.string :tipo_frecuencia
      t.integer :ancho_banda_desde
      t.integer :ancho_banda_hasta
      t.string :unidad_desde
      t.string :unidad_hasta
      t.belongs_to :espectro, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :frecuencia_espectros, :tipo_frecuencia
    add_index :frecuencia_espectros, :ancho_banda_desde
    add_index :frecuencia_espectros, :ancho_banda_hasta
    add_index :frecuencia_espectros, :unidad_desde
    add_index :frecuencia_espectros, :unidad_hasta
  end
end
