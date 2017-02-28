class CreateArbitros < ActiveRecord::Migration
  def change
    create_table :arbitros do |t|
      t.string :nombre_acreditado
      t.string :identificacion_acreditado

      t.timestamps null: false
    end
    add_index :arbitros, :nombre_acreditado
    add_index :arbitros, :identificacion_acreditado
  end
end
