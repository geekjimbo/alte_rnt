require 'enum'

class FrecuenciaEspectro < ActiveRecord::Base
  belongs_to :espectro, :foreign_key => "espectro_id"
  has_many :zona, dependent: :destroy, :foreign_key => "frecuenciaespectro_id"
  accepts_nested_attributes_for :zona, allow_destroy: true
  #validates_associated :zona

  #validates :tipo_frecuencia, inclusion: { in: %w(frecuencia_central rango_frecuencias) }
  #validates :ancho_banda_desde, numericality: true
  #validates :unidad_desde, presence: true, allow_nil: false

  TIPOS_FRECUENCIAS = Enum.new ([
        ["frecuencia", "Frecuencia"],
        ["frecuencia_tx_rx", "Frecuencia Rx-Tx"],
        ["rango_frecuencias", "Rango Frecuencias"],
        ["rango_frecuencias_tx_rx", "Rango Frecuencias Rx-Tx"],
      ])

  UNIDADES_FRECUENCIAS = Enum.new ([
        ["mhz", "MHz"],
        ["khz", "KHz"],
        ["ghz", "GHz"],
        ["hz", "Hz"]
      ])
end
