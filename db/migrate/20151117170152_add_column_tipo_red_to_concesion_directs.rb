class AddColumnTipoRedToConcesionDirects < ActiveRecord::Migration
  def change
    add_column :concesion_directs, :tipo_red, :string
  end
end
