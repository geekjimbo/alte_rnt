class CreateServicioHabilitados < ActiveRecord::Migration
  def change
    create_table :servicio_habilitados do |t|
      t.references :sciservicio, index: true, foreign_key: false
      t.belongs_to :titulo_habilitante, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
