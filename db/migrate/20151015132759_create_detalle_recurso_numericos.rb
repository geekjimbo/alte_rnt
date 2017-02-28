class CreateDetalleRecursoNumericos < ActiveRecord::Migration
  def change
    create_table :detalle_recurso_numericos do |t|
      t.string :rango_numeracion
      t.string :numero_asignado
      t.string :tipo_recurso_numerico
      t.text :nota
      t.references :recurso_numericos, index: true

      t.timestamps null: false
    end
  end
end
