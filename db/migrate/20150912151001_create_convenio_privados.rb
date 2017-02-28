class CreateConvenioPrivados < ActiveRecord::Migration
  def change
    create_table :convenio_privados do |t|
      t.string :titulo_convenio
      t.date :fecha_suscripcion
      t.integer :num_anexos
      t.text :nota

      t.timestamps null: false
    end
    add_index :convenio_privados, :titulo_convenio
    add_index :convenio_privados, :fecha_suscripcion
  end
end
