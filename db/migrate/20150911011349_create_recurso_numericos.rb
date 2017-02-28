class CreateRecursoNumericos < ActiveRecord::Migration
  def change
    create_table :recurso_numericos do |t|
      t.string :rango_numeracion
      t.string :numero_asignado
      t.string :tipo_recurso_numerico
      t.text :nota

      t.timestamps null: false
    end
    add_index :recurso_numericos, :rango_numeracion
    add_index :recurso_numericos, :numero_asignado
    add_index :recurso_numericos, :tipo_recurso_numerico
  end
end
