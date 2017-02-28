require 'enum'

class ConsecionPublica < ActiveRecord::Base
  has_one :espectro, as: :titulo, dependent: :destroy
  accepts_nested_attributes_for :espectro, allow_destroy: true
  validates_associated :espectro

  validates :numero_publicacion, presence: true, allow_nil: false
  validates :numero_notificacion_refrendo, presence: true, allow_nil: false
  validates :fecha_publicacion, presence: true, allow_nil: false 
  validates :fecha_emision, presence: true, allow_nil: false 
  validates :fecha_notificacion_refrendo, presence: true
  validates :tipo_red, presence: true, allow_nil: false, inclusion: { in: %w(publica privada) }

  TIPOS_RED = Enum.new([
          ["publica", "Red Pública"],
          ["privada", "Red Privada"]
       ])
end
