class RemoveColumnFromTituloHabilitante < ActiveRecord::Migration
  def change
    remove_column :titulo_habilitantes, :espectro_id, :string
  end
end
