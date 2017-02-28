class CreateFonatels < ActiveRecord::Migration
  def change
    create_table :fonatels do |t|
      t.string :titulo_informe
      t.text :nota

      t.timestamps null: false
    end
    add_index :fonatels, :titulo_informe
  end
end
