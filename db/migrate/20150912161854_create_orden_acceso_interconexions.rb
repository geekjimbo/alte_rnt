class CreateOrdenAccesoInterconexions < ActiveRecord::Migration
  def change
    create_table :orden_acceso_interconexions do |t|
      t.date :vigencia
      t.text :nota

      t.timestamps null: false
    end
    add_index :orden_acceso_interconexions, :vigencia
  end
end
