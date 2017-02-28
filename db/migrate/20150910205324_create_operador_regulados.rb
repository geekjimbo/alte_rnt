class CreateOperadorRegulados < ActiveRecord::Migration
  def change
    create_table :operador_regulados do |t|
      t.string :nombre
      t.string :identificacion
      t.string :codigo_operador
      t.string :nombre_representante_legal
      t.string :cedula_representante_legal

      t.timestamps null: false
    end
    add_index :operador_regulados, :nombre
    add_index :operador_regulados, :identificacion
    add_index :operador_regulados, :codigo_operador
    add_index :operador_regulados, :nombre_representante_legal
    add_index :operador_regulados, :cedula_representante_legal
  end
end
