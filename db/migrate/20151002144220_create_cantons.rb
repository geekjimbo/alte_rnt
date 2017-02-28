class CreateCantons < ActiveRecord::Migration
  def change
    create_table :cantons do |t|
      t.string :canton
      t.references :prov, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
