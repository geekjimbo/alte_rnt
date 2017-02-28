class ContratoAdhesion < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  validates_associated :asiento

  has_many :servicio_contrato_adhesions, dependent: :destroy, :foreign_key => :contrato_adhesions_id
  accepts_nested_attributes_for :servicio_contrato_adhesions, allow_destroy: true

  validates :titulo_contrato, presence: true
end
