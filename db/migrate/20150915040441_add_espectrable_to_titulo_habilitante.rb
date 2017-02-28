class AddEspectrableToTituloHabilitante < ActiveRecord::Migration
  def up
    change_table :titulo_habilitantes do |t|
        t.references :espectrable, :polymorphic => true
    end
  end

  def down
    change_table :titulo_habilitantes do |t|
        t.remove_references :espectrable, :polymorphic => true
    end
  end
end
