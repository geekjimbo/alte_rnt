class CreateTipoSancions < ActiveRecord::Migration
  def change
    create_table :tipo_sancions do |t|
      t.string :tipo_sancion

      t.timestamps null: false
    end
  end
end
