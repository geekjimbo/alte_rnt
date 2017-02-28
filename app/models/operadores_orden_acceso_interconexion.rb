class OperadoresOrdenAccesoInterconexion < ActiveRecord::Base
  belongs_to :operador_regulados, :foreign_key=>"operador_regulados_id"
  belongs_to :orden_acceso_interconexions, :foreign_key=>"orden_acceso_interconexions_id"
end
