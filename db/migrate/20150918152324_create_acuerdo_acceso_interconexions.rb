class CreateAcuerdoAccesoInterconexions < ActiveRecord::Migration
  def change
    create_table :acuerdo_acceso_interconexions do |t|
      t.string :titulo_acuerdo
      t.date :fecha_validez_acuerdo
      t.boolean :anexos
      t.boolean :adendas
      t.text :nota

      t.timestamps null: false
    end
    add_index :acuerdo_acceso_interconexions, :titulo_acuerdo
    add_index :acuerdo_acceso_interconexions, :fecha_validez_acuerdo
    add_index :acuerdo_acceso_interconexions, :anexos
    add_index :acuerdo_acceso_interconexions, :adendas
  end
end
