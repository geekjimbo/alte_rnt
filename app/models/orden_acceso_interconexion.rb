class OrdenAccesoInterconexion < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  has_many :operadores_orden_acceso_interconexions, dependent: :destroy, :foreign_key => "orden_acceso_interconexions_id"
  accepts_nested_attributes_for :operadores_orden_acceso_interconexions, allow_destroy: true

  validates_associated :asiento
end
