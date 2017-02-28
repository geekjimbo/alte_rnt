class CreateReglamentoTecnicos < ActiveRecord::Migration
  def change
    create_table :reglamento_tecnicos do |t|
      t.string :titulo_reglamento
      t.string :numero_aprobacion_aresep
      t.date :fecha_aprobacion
      t.text :nota

      t.timestamps null: false
    end
    add_index :reglamento_tecnicos, :titulo_reglamento
    add_index :reglamento_tecnicos, :numero_aprobacion_aresep
    add_index :reglamento_tecnicos, :fecha_aprobacion
  end
end
