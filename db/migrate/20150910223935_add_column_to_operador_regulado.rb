class AddColumnToOperadorRegulado < ActiveRecord::Migration
  def change
    add_column :operador_regulados, :estado, :string
    add_index :operador_regulados, :estado
  end
end
