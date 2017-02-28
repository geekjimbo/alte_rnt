class CreateEspectros < ActiveRecord::Migration
  def change
    create_table :espectros do |t|
      t.string :clasificacion_uso_espectro
      t.references :titulo, polymorphic: true, index: true

      t.timestamps null: false
    end
    add_index :espectros, :clasificacion_uso_espectro
  end
end
