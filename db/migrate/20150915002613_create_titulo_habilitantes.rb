class CreateTituloHabilitantes < ActiveRecord::Migration
  def change
    create_table :titulo_habilitantes do |t|
      t.string :numero_titulo
      t.date :fecha_titulo
      t.date :fecha_notificacion
      t.string :causal_finalizacion
      t.references :espectro, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :titulo_habilitantes, :numero_titulo
    add_index :titulo_habilitantes, :fecha_titulo
    add_index :titulo_habilitantes, :fecha_notificacion
    add_index :titulo_habilitantes, :causal_finalizacion
  end
end
