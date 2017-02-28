class OperadoresAcuerdoAccesoInterconexion < ActiveRecord::Base
  belongs_to :operador_regulados, :foreign_key=>"operador_regulados_id"
  belongs_to :acuerdo_acceso_interconexions, :foreign_key=>"acuerdo_acceso_interconexions_id"

  has_many :servicios_operadores_acuerdo_acceso_interconexions, dependent: :destroy, :foreign_key=>"operadores_acuerdo_acceso_interconexions_id"
  accepts_nested_attributes_for :servicios_operadores_acuerdo_acceso_interconexions, allow_destroy: true
end
