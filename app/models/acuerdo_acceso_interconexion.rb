class AcuerdoAccesoInterconexion < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true
  validates_associated :asiento
  
  has_many :servicios_interconexion, dependent: :destroy, :foreign_key => :acuerdo_acceso_interconexions_id
  accepts_nested_attributes_for :servicios_interconexion, allow_destroy: true

  has_many :operadores_acuerdo_acceso_interconexions, dependent: :destroy, :foreign_key=> "acuerdo_acceso_interconexions_id"
  accepts_nested_attributes_for :operadores_acuerdo_acceso_interconexions, allow_destroy: true

  validates :titulo_acuerdo, presence: true
  validates :fecha_validez_acuerdo, presence: true

end
