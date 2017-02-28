class AddColumnToOperadoresConvenioUbicacionEquipos < ActiveRecord::Migration
  def change
    add_column :operadores_convenio_ubicacion_equipos, :nombre_operador, :string
    add_index :operadores_convenio_ubicacion_equipos, :nombre_operador, :name=>"idx_operadores_cue_nombre_operador"
    add_column :operadores_convenio_ubicacion_equipos, :identificacion_operador, :string
    add_index :operadores_convenio_ubicacion_equipos, :identificacion_operador, :name=>"idx_operadores_cue_identificacion_operador"
    add_column :operadores_convenio_ubicacion_equipos, :nombre_representante_legal, :string
    add_index :operadores_convenio_ubicacion_equipos, :nombre_representante_legal, :name=>"idx_operadores_cue_nombre_rep_legal"
    add_column :operadores_convenio_ubicacion_equipos, :cedula_representante_legal, :string
    add_index :operadores_convenio_ubicacion_equipos, :cedula_representante_legal, :name=>"idx_operadores_cue_cedula_rep_legal"
  end
end
