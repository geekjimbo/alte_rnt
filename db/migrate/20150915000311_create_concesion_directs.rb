class CreateConcesionDirects < ActiveRecord::Migration
  def change
    create_table :concesion_directs do |t|

      t.timestamps null: false
    end
  end
end
