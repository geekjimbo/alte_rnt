class CreateNormas < ActiveRecord::Migration
  def change
    create_table :normas do |t|
      t.date :fecha_vigencia
      t.string :reforma
      t.text :nota

      t.timestamps null: false
    end
    add_index :normas, :fecha_vigencia
  end
end
