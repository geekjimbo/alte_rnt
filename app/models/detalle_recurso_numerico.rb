class DetalleRecursoNumerico < ActiveRecord::Base
  belongs_to :recurso_numericos, :foreign_key => "recurso_numericos_id"
  validates :rango_numeracion, presence: true
  validates :numero_asignado, presence: true
  validates :tipo_recurso_numerico, presence: true
end
