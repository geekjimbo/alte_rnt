class ResolucionUbicacionEquipo < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true

  has_many :operadores_resolucion_ubicacion_equipos, dependent: :destroy, :foreign_key => "resolucion_ubicacion_equipos_id"
  accepts_nested_attributes_for :operadores_resolucion_ubicacion_equipos, allow_destroy: true

  validates_associated :asiento
end
