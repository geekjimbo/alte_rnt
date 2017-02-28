class CreatePermisos < ActiveRecord::Migration
  def change
    create_table :permisos do |t|
      t.string :modalidad_permiso

      t.timestamps null: false
    end
    add_index :permisos, :modalidad_permiso
  end
end
