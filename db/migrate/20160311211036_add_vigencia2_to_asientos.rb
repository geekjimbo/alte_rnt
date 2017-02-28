class AddVigencia2ToAsientos < ActiveRecord::Migration
  def change
    add_column :asientos, :vigencia2, :string
  end
end
