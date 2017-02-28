class CreateOperadoresResolucionUbicacionEquipos < ActiveRecord::Migration
  def change
    create_table :operadores_resolucion_ubicacion_equipos do |t|
      t.string :nombre_operador
      t.string :identificacion_operador
      t.string :nombre_representante_legal
      t.string :cedula_representante_legal
      t.references :operador_regulados, index: {:name=>"idx_operadores_rue_operador_regulado"}
      t.references :resolucion_ubicacion_equipos, index: {:name=>"idx_operadores_rue_rue"}

      t.timestamps null: false
    end
    add_index :operadores_resolucion_ubicacion_equipos, :nombre_operador, :name=>"idx_operadores_rue"
    add_index :operadores_resolucion_ubicacion_equipos, :identificacion_operador, :name=>"idx_operadores_rue_id_operador"
    add_index :operadores_resolucion_ubicacion_equipos, :nombre_representante_legal, :name=>"idx_operadores_rue_rep_legal"
    add_index :operadores_resolucion_ubicacion_equipos, :cedula_representante_legal, :name=>"idx_operadores_rue_cedula_rep_legal"
  end
end
