class OfertaInterconexion < ActiveRecord::Base
  has_one :asiento, as: :acto, dependent: :destroy
  accepts_nested_attributes_for :asiento, allow_destroy: true
  validates_associated :asiento

  has_many :oferta_interconexion_servicios, dependent: :destroy, :foreign_key => :oferta_interconexions_id 
  accepts_nested_attributes_for :oferta_interconexion_servicios, allow_destroy: true
  #has_many :servicio_habilitado, dependent: :destroy
  #validates_associated :servicio_habilitado
  #accepts_nested_attributes_for :servicio_habilitado, allow_destroy: true

  validates :numero_publicacion_gaceta, presence: true
  validates :fecha_publicacion_gaceta, presence: true
end
