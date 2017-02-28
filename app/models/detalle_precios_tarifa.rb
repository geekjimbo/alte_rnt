class DetallePreciosTarifa < ActiveRecord::Base
  belongs_to :precios_tarifas, :foreign_key=>"precios_tarifas_id"
  belongs_to :sci_servicios, :foreign_key=>"sci_servicios_id"
end
