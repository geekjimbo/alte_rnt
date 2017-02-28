require 'enum'

class Zona < ActiveRecord::Base
  belongs_to :frecuencia_espectro, :foreign_key => "frecuenciaespectro_id"
  belongs_to :autorizacion, :foreign_key => "autorizacions_id"

  #validates :tipo_zona, inclusion: { in: %w(nacional regional poligono_cobertura) }

  TIPOS_ZONAS = Enum.new([
     ["nacional", "Cobertura Nacional"],
     ["regional", "Cobertura Regional"],
     ["poligono_cobertura", "Polígono de Cobertura (long/lat)"]
    ])
end
