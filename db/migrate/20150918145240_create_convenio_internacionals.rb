class CreateConvenioInternacionals < ActiveRecord::Migration
  def change
    create_table :convenio_internacionals do |t|
      t.string :titulo_convenio
      t.string :numero_ley_aprobacion
      t.date :fecha_vigencia
      t.text :enmiendas

      t.timestamps null: false
    end
    add_index :convenio_internacionals, :titulo_convenio
    add_index :convenio_internacionals, :numero_ley_aprobacion
  end
end
