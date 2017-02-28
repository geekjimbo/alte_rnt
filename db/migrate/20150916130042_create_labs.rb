class CreateLabs < ActiveRecord::Migration
  def change
    create_table :labs do |t|
      t.string :nombre_acreditado
      t.text :nota

      t.timestamps null: false
    end
  end
end
