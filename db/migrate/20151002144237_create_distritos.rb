class CreateDistritos < ActiveRecord::Migration
  def change
    create_table :distritos do |t|
      t.string :distrito
      t.references :canton, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
