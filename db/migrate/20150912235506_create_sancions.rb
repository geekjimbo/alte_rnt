class CreateSancions < ActiveRecord::Migration
  def change
    create_table :sancions do |t|
      t.string :tipo_sancion
      t.date :fecha_vigencia
      t.text :nota

      t.timestamps null: false
    end
    add_index :sancions, :tipo_sancion
    add_index :sancions, :fecha_vigencia
  end
end
