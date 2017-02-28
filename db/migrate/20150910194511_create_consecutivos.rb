class CreateConsecutivos < ActiveRecord::Migration
  def change
    create_table :consecutivos do |t|

      t.timestamps null: false
    end
  end
end
