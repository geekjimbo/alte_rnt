class ReglamentoTecnico < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  validates_associated :asiento

  validates :titulo_reglamento, presence: true
  validates :numero_aprobacion_aresep, presence: true
  validates :fecha_aprobacion, presence: true 
end
