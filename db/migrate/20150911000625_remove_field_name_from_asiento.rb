class RemoveFieldNameFromAsiento < ActiveRecord::Migration
  def change
    remove_column :asientos, :fg, :string
  end
end
