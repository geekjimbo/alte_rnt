class CreateAsientos < ActiveRecord::Migration
  def change
    create_table :asientos do |t|
      t.string :num_asiento
      t.string :num_asiento_original
      t.string :acto_inscribible
      t.string :tipo_asiento
      t.string :tipo_inscripcion
      t.string :numero_resolucion
      t.string :nombre_resolucion
      t.text :titulo_resolucion
      t.date :fecha_resolucion
      t.date :fecha_solicitud
      t.string :nombre_operador
      t.string :identificacion_operador
      t.string :nombre_representante_legal
      t.string :cedula_representante_legal
      t.string :usuario
      t.string :enlace_documento
      t.string :num_expediente_sutel
      t.references :operador_regulado, index: true, foreign_key: true, column: :operadorregulado_id
      t.string :fg

      t.timestamps null: false
    end
    add_index :asientos, :num_asiento
    add_index :asientos, :num_asiento_original
    add_index :asientos, :acto_inscribible
    add_index :asientos, :tipo_asiento
    add_index :asientos, :tipo_inscripcion
    add_index :asientos, :numero_resolucion
    add_index :asientos, :nombre_resolucion
    add_index :asientos, :fecha_resolucion
    add_index :asientos, :fecha_solicitud
    add_index :asientos, :identificacion_operador
    add_index :asientos, :cedula_representante_legal
  end
end
