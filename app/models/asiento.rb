require 'enum'

class Asiento < ActiveRecord::Base

  after_initialize :set_defaults
  belongs_to :acto, polymorphic: true
  #has_many :recurso_numericos, foreign_key: :asientos_id
  #has_many :modificaciones, class_name: "Asiento", foreign_key: :num_asiento_original
  #belongs_to :asiento_original, class_name: "Asiento"

  has_attached_file :fichero
  validates_attachment_content_type :fichero, :content_type => ["image/pdf","image/jpg", "image/jpeg", "image/png", "image/gif"]

  def fichero_gdrive
    @fichero_gdrive
  end

  def fichero_gdrive=(valor)
    @fichero_gdrive = valor
  end

  validates :acto_inscribible, presence: true, allow_nil: false
  validates :tipo_asiento, presence: true, inclusion: { in: %w(AS MD) }, allow_nil: false
  #validates :vigencia, numericality: true, length: { maximum: 999 }

  CAMPOS_BUSQUEDA = Enum.new([
      [:todos, "Todos"],
      [:num_asiento, "Número Asiento"],
      [:num_asiento_original, "Número Asiento Original"],
      [:acto_inscribible, "Acto Inscribible"],
      [:tipo_asiento, "Tipo Asiento"],
      [:numero_resolucion, "Número"],
      [:titulo_resolucion, "Título"],
      [:fecha_resolucion, "Fecha"],
      [:fecha_solicitud, "Fecha Solicitud"],
      [:nombre_operador, "Nombre Operador"],
      [:identificacion_operador, "Identificación Operador"],
      [:usuario, "Email del Usuario"]
      ])

  TIPO_ASIENTO = Enum.new([
      ["ED", 'Editar Datos del Asiento'],
      ["MD", 'Modificación de Asiento']
      ])

  TIPO_TRAMITE = Enum.new([
      [:new_arbitro,"Acreditación Arbitros/Peritos"],
      [:new_acuerdo_acceso_interconexion,"Acuerdo Acceso e Interconexión"],
      [:new_precios_tarifa,"Aprobación de Precios y Tarifas"],
      [:new_contrato_adhesion,"Contrato Adhesión"],
      [:new_convenio_privado,"Convenio Privado para el intercambio de tráfico internacional"],
      [:new_convenio_internacional,"Convenio Internacional"],
      [:new_convenio_ubicacion_equipo,"Convenio Ubicación Equipos"],
      [:new_homologacion,"Lista de Homologación Equipos"],
      [:new_fonatel,"Informe Fonatel"],
      [:new_lab,"Laboratorio"],
      [:new_norma,"Norma y Estándar de Calidad"],
      [:new_oferta_interconexion,"Oferta Interconexión"],
      [:new_orden_acceso_interconexion,"Orden Acceso Interconexión"],
      [:new_reglamento_tecnico,"Reglamentos Técnicos"],
      [:new_recurso_numerico,"Recurso de Numeración"],
      [:new_resolucion_ubicacion_equipo,"Resoluciónes sobre Ubicación de Equipos, colocación y el uso compartido de infraestructuras físicas"],
      [:new_sancion,"Sanción Impuesta por resolución en firme"],
      [:new_autorizacion,"Titulo Habilitante - Autorizaciones"],
      [:new_concesion_direct,"Titulo Habilitante - Concesiones Directas"],
      [:new_consecion_publica,"Titulo Habilitante - Concesiones Concurso Público"],
      [:new_consecion_anterior,"Titulo Habilitante - Concesiones Anterior a la Ley"],
      [:new_permiso,"Titulo Habilitante - Espectro - Permiso"]
      ])

  def self.search(search, field)
    if field != "todos"
      if search
        where("lower(#{field}) LIKE lower(?)", "%#{search}%")
      end
    else
      all
    end
  end

  def set_defaults
    self.fecha_solicitud = Time.now
  end
  
  def historico?
       0
  end
end
