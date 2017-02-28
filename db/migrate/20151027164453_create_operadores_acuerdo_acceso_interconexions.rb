class CreateOperadoresAcuerdoAccesoInterconexions < ActiveRecord::Migration
  def change
    create_table :operadores_acuerdo_acceso_interconexions do |t|
      t.string :nombre_operador
      t.string :identificacion_operador
      t.string :nombre_representante_legal
      t.string :cedula_representante_legal
      t.references :operador_regulados, index: {:name=>"idx_operadores_aai"}
      t.references :acuerdo_acceso_interconexions, index: {:name=>"idx_operadores_aai_aai"}

      t.timestamps null: false
    end
    add_index :operadores_acuerdo_acceso_interconexions, :nombre_operador, :name=>"operadores_aai_nombre_operador"
    add_index :operadores_acuerdo_acceso_interconexions, :identificacion_operador, :name=>"operadores_aai_id_operador"
    add_index :operadores_acuerdo_acceso_interconexions, :nombre_representante_legal, :name=>"operadores_aai_rep_legal"
    add_index :operadores_acuerdo_acceso_interconexions, :cedula_representante_legal, :name=>"operadores_aai_cedula_rep_legal"
  end
end
