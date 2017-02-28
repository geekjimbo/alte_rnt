class CreateContratoAdhesions < ActiveRecord::Migration
  def change
    create_table :contrato_adhesions do |t|
      t.string :titulo_contrato
      t.date :fecha_vigencia
      t.boolean :estado_contrato
      t.text :nota

      t.timestamps null: false
    end
    add_index :contrato_adhesions, :titulo_contrato
    add_index :contrato_adhesions, :fecha_vigencia
    add_index :contrato_adhesions, :estado_contrato
  end
end
