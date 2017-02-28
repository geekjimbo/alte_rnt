require 'nested_servicios'

class PermisosController < ApplicationController
  #before_action :set_permiso, only: [:show, :edit, :update, :destroy]
  
  PER_PAGE = 10

  def index
    @permisos = Permiso.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @permiso = Permiso.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @permiso = Permiso.new

    #build stack up
    @permiso.build_espectro
    @permiso.espectro.build_titulo_habilitante
    @permiso.espectro.titulo_habilitante.build_asiento

    @anatext_asiento = check_for_anatext @permiso.espectro.titulo_habilitante.asiento
    @permiso.espectro.titulo_habilitante.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @permiso.espectro.titulo_habilitante.asiento.tipo_asiento = "AS"
    @permiso.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Asiento Nuevo"
    @espectro = @permiso.espectro
    @titulo_habilitante = @permiso.espectro.titulo_habilitante
    @asiento = @permiso.espectro.titulo_habilitante.asiento

    # load anatext if any
    #@permiso.espectro.titulo_habilitante.asiento = check_for_anatext @permiso.espectro.titulo_habilitante.asiento

    # build childs
    @permiso.espectro.frecuencia_espectro.new
    #@permiso.espectro.frecuencia_espectro.first.zona.new
    #@permiso.espectro.titulo_habilitante.servicio_habilitados.new
    @frecuencia_espectro = @permiso.espectro.frecuencia_espectro.first
    #@zona = @permiso.espectro.frecuencia_espectro.first.zona.first
    #@servicio_habilitado = @permiso.espectro.titulo_habilitante.servicio_habilitados.first
  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
    @permiso = Permiso.find(params[:id])

    # stack up
    @espectro = @permiso.espectro
    @titulo_habilitante = @permiso.espectro.titulo_habilitante
    @asiento = @permiso.espectro.titulo_habilitante.asiento
    @permiso.espectro.titulo_habilitante.asiento.tipo_asiento = "ED"
    #@permiso.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Modificación de Asiento"

    # childs
    @permiso.espectro.frecuencia_espectro.new if @permiso.espectro.frecuencia_espectro.first.nil?
    @permiso.espectro.frecuencia_espectro.first.zona.new if @permiso.espectro.frecuencia_espectro.first.zona.first.nil?
    @permiso.espectro.titulo_habilitante.servicio_habilitados.new if @permiso.espectro.titulo_habilitante.servicio_habilitados.nil?

    @frecuencia_espectro = @permiso.espectro.frecuencia_espectro.all 
    @zona = @permiso.espectro.frecuencia_espectro.first.zona.all 
    @servicio_habilitado = @permiso.espectro.titulo_habilitante.servicio_habilitados.all   
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@permiso = Permiso.new(permiso_params)

    if !is_asiento_nil? 
      if @permiso.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Permiso creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Permiso no creado, hay errores que corregir' 
        render :new
      end
    else
        render :new
    end
  end

  def update
    set_asientos_fields
 end

  def delete
  end

  def destroy
    Permiso.find(params[:id]).destroy
    flash.now[:success] = "Permiso borrado"
    redirect_to permisos_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permiso
      @permiso = Permiso.find(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def permiso_params
        unless params[:permiso].empty? 
          params.require(:permiso).permit(:id, :modalidad_permiso, espectro_attributes: [:id, :clasificacion_uso_espectro, :titulo_id, [frecuencia_espectro_attributes: [:tipo_frecuencia, :desde, :hasta, :tx_desde, :tx_hasta, :rx_desde, :rx_hasta, :unidad_desde, :unidad_hasta, :espectro_id, [zona_attributes: [:tipo_zona, :descripcion_zona, :frecuenciaespectro_id, :provincia, :canton, :distrito, :nota]]]] ,:titulo_type, [titulo_habilitante_attributes: [:id, :numero_titulo, :fecha_titulo, :fecha_notificacion, :causal_finalizacion, :espectrable_id, :espectrable_type, [servicio_habilitados_attributes: [:sciservicio_id, :titulo_habilitante_id, :nota, :servicio]] , asiento: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ]]]])
        end
    end
    
    def is_asiento_nil?
      #check_stack_for_nil
      #@permiso.espectro.titulo_habilitante.asiento.nil?
      @permiso.espectro.titulo_habilitante.nil?
    end

    def set_asientos_fields
      rn = params[:permiso][:espectro_attributes][:asiento]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          rn[:fecha_solicitud] = Time.now
        end

        rn[:acto_inscribible] = "Permiso"
        if rn[:nombre_operador].blank? or rn[:identificacion_operador].blank? and !rn[:operadorregulado_id].blank?
          @operador = OperadorRegulado.find(rn[:operadorregulado_id])
          rn[:nombre_operador] = @operador.nombre
          rn[:identificacion_operador] = @operador.identificacion
          rn[:nombre_representante_legal] = @operador.nombre_representante_legal
          rn[:cedula_representante_legal] = @operador.cedula_representante_legal
        end
        rn[:usuario] = current_user.id.to_s + "-" + current_user.email

        if action_name == 'update'
          clonar_objetos
        end
      end

    end


    def clonar_objetos
      # clonar el permiso y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto permiso
      my_hash = params[:permiso]
      permiso = deep_copy(Permiso, my_hash, params[:id])
      @permiso = permiso 

      if @permiso.save
        @consecutivo.save if !@consecutivo.nil?
        flash.now[:success] = "Permiso actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Permiso no modificado, hay errores que corregir' 
        render :edit
      end
   end

    def handle_servicios
      n = Nested.new
      my_hash = params[:permiso][:espectro_attributes][:titulo_habilitante_attributes][:servicio_habilitados_attributes]
      n.servicios :action => :update, :titulo_habilitante_id => @autorizacion.titulo_habilitante.id, :hash_fresh => my_hash
    end

    def check_stack_for_nil
      #build stack up
      @permiso.build_espectro if @permiso.espectro.nil? 
      @permiso.espectro.build_titulo_habilitante if @permiso.espectro.titulo_habilitante.nil?
      @permiso.espectro.titulo_habilitante.build_asiento if @permiso.espectro.titulo_habilitante.asiento.nil?
      @permiso.espectro.frecuencia_espectro.new if @permiso.espectro.frecuencia_espectro.first.nil?
      #@permiso.espectro.frecuencia_espectro.first.zona.new if !@permiso.espectro.frecuencia_espectro.first.zona.any?
      @permiso.espectro.titulo_habilitante.servicio_habilitados.new if !@permiso.espectro.titulo_habilitante.servicio_habilitados.any?
    end

    def create_ancestors_from_hash
      @permiso = Permiso.new(permiso_params) if action_name == "create"
      @permiso = Permiso.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:permiso][:espectro_attributes][:titulo_habilitante_attributes]

      # clonar titulo_habilitante
      @permiso.espectro.titulo_habilitante.numero_titulo = hash[:numero_titulo]
      @permiso.espectro.titulo_habilitante.fecha_titulo = hash[:fecha_titulo]
      @permiso.espectro.titulo_habilitante.fecha_notificacion = hash[:fecha_notificacion]
      @permiso.espectro.titulo_habilitante.causal_finalizacion = hash[:causal_finalizacion]
      @permiso.espectro.titulo_habilitante.espectrable_id = hash[:espectrable_id]
      @permiso.espectro.titulo_habilitante.espectrable_type = "Espectro"

      hash = params[:permiso][:espectro_attributes][:asiento]
      @permiso.espectro.titulo_habilitante.asiento.num_asiento = hash[:num_asiento] if action_name == "create"
      @permiso.espectro.titulo_habilitante.asiento.num_asiento_original = hash[:num_asiento_original]
      @permiso.espectro.titulo_habilitante.asiento.acto_inscribible = hash[:acto_inscribible]
      @permiso.espectro.titulo_habilitante.asiento.tipo_asiento = hash[:tipo_asiento]
      @permiso.espectro.titulo_habilitante.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @permiso.espectro.titulo_habilitante.asiento.numero_resolucion = hash[:numero_resolucion]
      @permiso.espectro.titulo_habilitante.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @permiso.espectro.titulo_habilitante.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @permiso.espectro.titulo_habilitante.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @permiso.espectro.titulo_habilitante.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @permiso.espectro.titulo_habilitante.asiento.nombre_operador = hash[:nombre_operador]
      @permiso.espectro.titulo_habilitante.asiento.identificacion_operador = hash[:identificacion_operador]
      @permiso.espectro.titulo_habilitante.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @permiso.espectro.titulo_habilitante.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @permiso.espectro.titulo_habilitante.asiento.usuario = hash[:usuario]
      @permiso.espectro.titulo_habilitante.asiento.enlace_documento = hash[:enlace_documento]
      @permiso.espectro.titulo_habilitante.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @permiso.espectro.titulo_habilitante.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @permiso.espectro.titulo_habilitante.asiento.vigencia2 = hash[:vigencia2]
      @permiso.espectro.titulo_habilitante.asiento.acto_id = hash[:acto_id]
      @permiso.espectro.titulo_habilitante.asiento.acto_type = "TituloHabilitante"

      # clonar servicios habilitados

      # clonar frecuencias
      #hash = params[:permiso][:frecuencia_espectro]
      #@permiso.espectro.frecuencia_espectro.first.tipo_frecuencia = hash[:tipo_frecuencia]
      #@permiso.espectro.frecuencia_espectro.first.ancho_banda_desde = hash[:ancho_banda_desde]
      #@permiso.espectro.frecuencia_espectro.first.ancho_banda_hasta = hash[:ancho_banda_hasta]
      #@permiso.espectro.frecuencia_espectro.first.unidad_desde = hash[:unidad_desde]
      #@permiso.espectro.frecuencia_espectro.first.espectro_id = hash[:espectro_id]
      
      # clonar zonas
      #hash = params[:permiso][:espectro_attributes][:frecuencia_espectro][:zona]
      #@permiso.espectro.frecuencia_espectro.first.zona.first.tipo_zona = hash[:tipo_zona]
      #@permiso.espectro.frecuencia_espectro.first.zona.first.descripcion_zona = hash[:descripcion_zona]
      #@permiso.espectro.frecuencia_espectro.first.zona.first.nota = hash[:nota]
      #@permiso.espectro.frecuencia_espectro.first.zona.first.frecuenciaespectro_id = hash[:frecuenciaespectro_id]
    end
end
