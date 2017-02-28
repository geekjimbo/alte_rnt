class CreateSciServicios < ActiveRecord::Migration
  def change
    create_table :sci_servicios do |t|
      t.string :descripcion

      t.timestamps null: false
    end
    add_index :sci_servicios, :descripcion
  end
end
