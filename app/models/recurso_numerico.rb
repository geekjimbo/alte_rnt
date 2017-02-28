require 'enum'

class RecursoNumerico < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  validates_associated :asiento

  has_many :detalle_recurso_numericos, dependent: :destroy, :foreign_key => "recurso_numericos_id"
  accepts_nested_attributes_for :detalle_recurso_numericos, allow_destroy: true

  #validates :rango_numeracion, presence: true
  #validates :numero_asignado, presence: true
  #validates :tipo_recurso_numerico, presence: true
  #validates :nota

  TIPO_RECURSO = Enum.new([
      [:ochodigitos, 'Usuario final 8 dígitos'],
      [:revertido800, 'Servicios de Cobro Revertido numeración 800-10 dígitos'],
      [:numeracion900,'Servicios de llamadas de contenido numeración 900-10 dígitos'],
      [:especial4digitos, 'Servicios de numeración especial de cuatro dígitos'],
      [:mms, 'Servicios MMS'],
      [:numeracion, 'Servicios de numeración'],
      [:maritimo_mmsi, 'Servicios de numeración móvil marítimo MMSI'],
      [:aeronautica, 'Servicios de numeración aeronáutica'],
      [:sms_4digitos, 'Servicios Especiales de numeración corta cuatro dígitos Mensajería de Texto SMS'],
      [:especial905, 'Servicios especiales de llamadas masivas - numeración 905s'],
      [:especial900, 'Servicios especiales de Servicios de Información - numeración 900s']
      ])
end

