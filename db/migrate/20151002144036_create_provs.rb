class CreateProvs < ActiveRecord::Migration
  def change
    create_table :provs do |t|
      t.string :provincia

      t.timestamps null: false
    end
  end
end
