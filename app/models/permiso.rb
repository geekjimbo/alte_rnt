require 'enum'

class Permiso < ActiveRecord::Base
  has_one :espectro, as: :titulo, dependent: :destroy
  accepts_nested_attributes_for :espectro, allow_destroy: true
  validates_associated :espectro

  validates :modalidad_permiso, presence: true, allow_nil: false, inclusion: { in: %w(radioaficionado banda_ciudadana radiocomunicacion_banda_angosta radiocomunicacion_banda_aeronautica radiocomunicacion_banda_marina otros) }

  MODALIDADES_PERMISOS = Enum.new([
           ["radioaficionado", "Permiso de Radioaficionado"],
           ["banda_ciudadana", "Permiso de Banda Ciudadana"],
           ["radiocomunicacion_banda_angosta", "Permiso Radiocomunicación Banda Angosta"],
           ["radiocomunicacion_banda_aeronautica", "Permiso Radiocomunicación Banda Aeronáutica"],
           ["radiocomunicacion_banda_marina", "Permiso Radiocomunicación Banda Marina"],
           ["otros", "Otras modalidades de permisos"]
  ] )

end
