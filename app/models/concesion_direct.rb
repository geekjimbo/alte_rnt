require 'Enum'
class ConcesionDirect < ActiveRecord::Base
  has_one :espectro, as: :titulo, dependent: :destroy
  accepts_nested_attributes_for :espectro, allow_destroy: true
  validates_associated :espectro

  TIPOS_RED = Enum.new([
          ["publica", "Red Pública"],
          ["privada", "Red Privada"]
       ])
end
