require 'enum'

class Espectro < ActiveRecord::Base
  belongs_to :titulo, polymorphic: true

  has_one :titulo_habilitante, as: :espectrable, dependent: :destroy
  accepts_nested_attributes_for :titulo_habilitante, allow_destroy: true
  validates_associated :titulo_habilitante

  has_many :frecuencia_espectro, dependent: :destroy, :foreign_key => "espectro_id", :class_name => "FrecuenciaEspectro"
  accepts_nested_attributes_for :frecuencia_espectro, allow_destroy: true
  #validates_associated :frecuencia_espectro

  validates :clasificacion_uso_espectro, presence: true, inclusion: { in: %w(no_aplica uso_comercial uso_no_comercial uso_oficial uso_seguridad_socorro_emergencia uso_libre) }

  CLASIFICACION_USO = Enum.new ([
        ["no_aplica", "No Aplica"],
        ["uso_comercial", "Uso Comercial"],
        ["uso_no_comercial", "Uso No Comercial"],
        ["uso_oficial", "Uso Oficial"],
        ["uso_seguridad_socorro_emergencia", "Uso Seguridad, Socorro y Emergencia"],
        ["uso_libre", "Uso Libre"]
      ])

end
