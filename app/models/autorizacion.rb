require 'enum'

class Autorizacion < ActiveRecord::Base
  has_one :titulo_habilitante, as: :espectrable, dependent: :destroy
  accepts_nested_attributes_for :titulo_habilitante, allow_destroy: true
  validates_associated :titulo_habilitante
  
  has_many :zona, dependent: :destroy, :foreign_key => "autorizacions_id"
  accepts_nested_attributes_for :zona, allow_destroy: true
  #has_many :zonas, dependent: :destroy
  #accepts_nested_attributes_for :zonas, allow_destroy: true

  validates :numero_publicacion_gaceta, presence: true, allow_nil: false
  validates :fecha_publicacion_gaceta, presence: true, allow_nil: false
  validates :tipo_red, presence: true, inclusion: { in: %w(publica privada) }

  TIPOS_RED = Enum.new([
          ["publica", "Red Pública"],
          ["privada", "Red Privada"]
       ])

end
