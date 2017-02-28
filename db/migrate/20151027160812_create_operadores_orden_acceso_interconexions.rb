class CreateOperadoresOrdenAccesoInterconexions < ActiveRecord::Migration
  def change
    create_table :operadores_orden_acceso_interconexions do |t|
      t.string :nombre_operador
      t.string :identificacion_operador
      t.string :nombre_representante_legal
      t.string :cedula_representante_legal
      t.references :operador_regulados, index: {:name=>"idx_operadores_oai"}
      t.references :orden_acceso_interconexions, index: {:name=>"idx_oai"}

      t.timestamps null: false
    end
    add_index :operadores_orden_acceso_interconexions, :nombre_operador, :name=>"idx_operadores_oai_nombre_operador"
    add_index :operadores_orden_acceso_interconexions, :identificacion_operador, :name=>"idx_operadores_oai_id_operador"
    add_index :operadores_orden_acceso_interconexions, :nombre_representante_legal, :name=>"idx_operadores_oai_nombre_rep_legal"
    add_index :operadores_orden_acceso_interconexions, :cedula_representante_legal, :name=>"idx_operadores_oai_cedula_rep_legal"
  end
end
