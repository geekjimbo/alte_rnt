class AddFieldToReglamentoTecnico < ActiveRecord::Migration
  def change
    add_column :reglamento_tecnicos, :fecha_vigencia, :date
    add_column :reglamento_tecnicos, :reformas, :text
  end
end
