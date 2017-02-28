class AddIndexToTituloHabilitantesEspectrableType < ActiveRecord::Migration
  def change
    add_index :titulo_habilitantes, :espectrable_type
    add_index :titulo_habilitantes, :espectrable_id
  end
end
