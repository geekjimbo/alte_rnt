class ConsecionAnterior < ActiveRecord::Base
  has_one :espectro, as: :titulo, dependent: :destroy
  accepts_nested_attributes_for :espectro, allow_destroy: true
  #validates_associated :espectro

  #validates :fecha_adecuacion_poder_ejecutivo, presence: true, allow_nil: false
end
