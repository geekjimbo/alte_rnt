require 'enum'

class TituloHabilitante < ActiveRecord::Base
  belongs_to :espectrable, polymorphic: true

  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true
  validates_associated :asiento
  
  has_many :servicio_habilitados, dependent: :destroy
  validates_associated :servicio_habilitados
  accepts_nested_attributes_for :servicio_habilitados, allow_destroy: true

  validates :numero_titulo, presence: true
  validates :fecha_titulo, presence: true

  CAUSAL_FINALIZACION = Enum.new ([
       [:no_aplica, "n/a"],
       [:adecuacion, "Adecuación"],
       [:extincion, "Extinción"],
       [:reasignacion, "Reasignación"]
      ])
end
