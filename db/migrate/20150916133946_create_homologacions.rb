class CreateHomologacions < ActiveRecord::Migration
  def change
    create_table :homologacions do |t|
      t.string :numero_oficio_remision
      t.date :fecha_actualizacion
      t.text :nota

      t.timestamps null: false
    end
    add_index :homologacions, :numero_oficio_remision
    add_index :homologacions, :fecha_actualizacion
  end
end
