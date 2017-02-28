class AddFieldToConvenioPrivado < ActiveRecord::Migration
  def change
    add_column :convenio_privados, :fecha_vencimiento, :date
    add_column :convenio_privados, :adendas, :string
  end
end
