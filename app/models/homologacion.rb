class Homologacion < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  validates_associated :asiento

  validates :numero_oficio_remision, presence: true
  validates :fecha_actualizacion, presence: true
end
