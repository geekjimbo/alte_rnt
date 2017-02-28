class PreciosTarifa < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true
  validates_associated :asiento

  has_many :detalle_precios_tarifas, dependent: :destroy, :foreign_key=>"precios_tarifas_id"
  accepts_nested_attributes_for :detalle_precios_tarifas, allow_destroy: true

  validates :numero_publicacion_gaceta, presence: true
  validates :fecha_publicacion_gaceta, presence: true

  TIPO_ESTADO = Enum.new([
      ["VIGENTE", 'Vigente'],
      ["NO_VIGENTE", 'No Vigente']
      ])

  TIPO_PRECIO_TARIFA = Enum.new([
      ["tarifa_maxima_acceso", 'Tarifa Máxima por Acceso'],
      ["tarifa_maxima_minuto", 'Tarifa Máxima por Minuto']
      ])
end
