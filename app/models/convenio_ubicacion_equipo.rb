class ConvenioUbicacionEquipo < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  has_many :operadores_convenio_ubicacion_equipos, dependent: :destroy, :foreign_key => "convenio_ubicacion_equipos_id"

  accepts_nested_attributes_for :operadores_convenio_ubicacion_equipos, allow_destroy: true
  accepts_nested_attributes_for :asiento, allow_destroy: true
  validates_associated :asiento
  
  validates :titulo_convenio, presence: true
end
