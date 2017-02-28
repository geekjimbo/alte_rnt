class ConcesionDirectsController < ApplicationController
  
  PER_PAGE = 10

  def index
    @concesiondirects = ConcesionDirect.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @concesiondirect = ConcesionDirect.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @concesiondirect = ConcesionDirect.new

    #build stack up
    @concesiondirect.build_espectro
    @concesiondirect.espectro.build_titulo_habilitante
    @concesiondirect.espectro.titulo_habilitante.build_asiento

    @anatext_asiento = check_for_anatext @concesiondirect.espectro.titulo_habilitante.asiento
    @concesiondirect.espectro.titulo_habilitante.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @concesiondirect.espectro.titulo_habilitante.asiento.tipo_asiento = "AS"
    @concesiondirect.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Asiento Nuevo"
    
    # get anatext hash
    #if !session[:anatext_file_name].nil? and !session[:anatext_file_name].empty?
    #  anatext_hash = {}
    #  anatext_hash = get_anatext_hash session[:anatext_file_name]
    #  @concesiondirect.espectro.titulo_habilitante.asiento = cargar_anatext @concesiondirect.espectro.titulo_habilitante.asiento, anatext_hash
    #end

    #@concesiondirect.espectro.titulo_habilitante.asiento = check_for_anatext @concesiondirect.espectro.titulo_habilitante.asiento

    @espectro = @concesiondirect.espectro
    @titulo_habilitante = @concesiondirect.espectro.titulo_habilitante
    @asiento = @concesiondirect.espectro.titulo_habilitante.asiento

    # build childs
    @concesiondirect.espectro.frecuencia_espectro.new
    #@concesiondirect.espectro.frecuencia_espectro.first.zona.new
    #@concesiondirect.espectro.titulo_habilitante.servicio_habilitados.new
    @frecuencia_espectro = @concesiondirect.espectro.frecuencia_espectro.first
    #@zona = @concesiondirect.espectro.frecuencia_espectro.first.zona.first
    #@servicio_habilitado = @concesiondirect.espectro.titulo_habilitante.servicio_habilitados.first

  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
	res = ConcesionDirect.find(params[:id]).nil? rescue true 
	redirect_to asientos_path if res 
    @concesiondirect = ConcesionDirect.find(params[:id])

    # stack up
    @espectro = @concesiondirect.espectro
    @titulo_habilitante = @concesiondirect.espectro.titulo_habilitante
    @asiento = @concesiondirect.espectro.titulo_habilitante.asiento
    @concesiondirect.espectro.titulo_habilitante.asiento.tipo_asiento = "ED"
    #@concesiondirect.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Modificación de Asiento"

    @espectro = @concesiondirect.espectro

    # childs
    @concesiondirect.espectro.frecuencia_espectro.new if @concesiondirect.espectro.frecuencia_espectro.first.nil?
    @concesiondirect.espectro.frecuencia_espectro.first.zona.new if @concesiondirect.espectro.frecuencia_espectro.first.zona.first.nil?
    @concesiondirect.espectro.titulo_habilitante.servicio_habilitados.new if @concesiondirect.espectro.titulo_habilitante.servicio_habilitados.nil?

    @frecuencia_espectro = @concesiondirect.espectro.frecuencia_espectro.all 
    @zona = @concesiondirect.espectro.frecuencia_espectro.first.zona.all 
    @servicio_habilitado = @concesiondirect.espectro.titulo_habilitante.servicio_habilitados.all   
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@concesiondirect = concesiondirect.new(concesiondirect_params)

    if !is_asiento_nil? 
      if @concesiondirect.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Conseción Directa creada exitosamente"
        redirect_to asientos_path
        #redirect_to concesiondirects_url
      else
        flash.now[:danger] = 'Conseción Directa no creada, hay errores que corregir' 
        render :new
      end
    else
        redirect_to asientos_path
    end
  end

  def update
    set_asientos_fields
  end

  def delete
  end

  def destroy
    concesiondirect.find(params[:id]).destroy
    flash.now[:success] = "Conseción Directa borrada"
    redirect_to concesiondirects_url
  end


  private

    # Use callbacks to share common setup or constraints between actions.
    def set_concesion_direct
      @concesion_direct = ConcesionDirect.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def concesiondirect_params
        unless params[:concesion_direct].empty? 
          params.require(:concesion_direct).permit(:id, :fecha_vencimiento, :tipo_red, espectro_attributes: [:id, :clasificacion_uso_espectro, :titulo_id, [frecuencia_espectro_attributes: [:tipo_frecuencia, :desde, :hasta, :tx_desde, :tx_hasta, :rx_desde, :rx_hasta, :unidad_desde, :unidad_hasta, :espectro_id, [zona_attributes: [:tipo_zona, :descripcion_zona, :frecuenciaespectro_id, :provincia, :canton, :distrito, :nota]]]] ,:titulo_type, [titulo_habilitante_attributes: [:id, :numero_titulo, :fecha_titulo, :fecha_notificacion, :causal_finalizacion, :espectrable_id, :espectrable_type, [servicio_habilitados_attributes: [:sciservicio_id, :titulo_habilitante_id,:nota, :servicio]] , asiento: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ]]]])
        end
    end
    
    def is_asiento_nil?
      #check_stack_for_nil
      #@concesiondirect.espectro.titulo_habilitante.asiento.nil?
      @concesiondirect.espectro.titulo_habilitante.nil?
    end

    def set_asientos_fields
      rn = params[:concesion_direct][:espectro_attributes][:asiento]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          rn[:fecha_solicitud] = Time.now
        end

        rn[:acto_inscribible] = "concesiondirect"
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
      # clonar el concesiondirect y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto concesiondirect
      my_hash = params[:concesion_direct]
      concesiondirect = deep_copy(ConcesionDirect, my_hash, params[:id])
      @concesiondirect = concesiondirect

      if @concesiondirect.save
        @consecutivo.save if !@consecutivo.nil?
        flash.now[:success] = "Conseción Directa actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Conseción Directa no modificado, hay errores que corregir' 
        render :edit
      end
    end

    def handle_servicios
      n = Nested.new
      my_hash = params[:concesion_direct][:espectro_attributes][:titulo_habilitante_attributes][:servicio_habilitados_attributes]
      n.servicios :action => :update, :titulo_habilitante_id => @autorizacion.titulo_habilitante.id, :hash_fresh => my_hash
    end

    def check_stack_for_nil
      #build stack up
      @concesiondirect.build_espectro if @concesiondirect.espectro.nil? 
      @concesiondirect.espectro.build_titulo_habilitante if @concesiondirect.espectro.titulo_habilitante.nil?
      @concesiondirect.espectro.titulo_habilitante.build_asiento if @concesiondirect.espectro.titulo_habilitante.asiento.nil?
      @concesiondirect.espectro.frecuencia_espectro.new if @concesiondirect.espectro.frecuencia_espectro.first.nil?
      #@concesiondirect.espectro.frecuencia_espectro.first.zona.new if !@concesiondirect.espectro.frecuencia_espectro.first.zona.any?
      @concesiondirect.espectro.titulo_habilitante.servicio_habilitados.new if !@concesiondirect.espectro.titulo_habilitante.servicio_habilitados.any?
    end

    def create_ancestors_from_hash
      @concesiondirect = ConcesionDirect.new(concesiondirect_params) if action_name == "create"
      @concesiondirect = ConcesionDirect.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:concesion_direct][:espectro_attributes][:titulo_habilitante_attributes]

      # clonar titulo_habilitante
      @concesiondirect.espectro.titulo_habilitante.numero_titulo = hash[:numero_titulo]
      @concesiondirect.espectro.titulo_habilitante.fecha_titulo = hash[:fecha_titulo]
      @concesiondirect.espectro.titulo_habilitante.fecha_notificacion = hash[:fecha_notificacion]
      @concesiondirect.espectro.titulo_habilitante.causal_finalizacion = hash[:causal_finalizacion]
      @concesiondirect.espectro.titulo_habilitante.espectrable_id = hash[:espectrable_id]
      @concesiondirect.espectro.titulo_habilitante.espectrable_type = "Espectro"

      hash = params[:concesion_direct][:espectro_attributes][:asiento]
      @concesiondirect.espectro.titulo_habilitante.asiento.num_asiento = hash[:num_asiento] if action_name == "create"
      @concesiondirect.espectro.titulo_habilitante.asiento.num_asiento_original = hash[:num_asiento_original]
      @concesiondirect.espectro.titulo_habilitante.asiento.acto_inscribible = hash[:acto_inscribible]
      @concesiondirect.espectro.titulo_habilitante.asiento.tipo_asiento = hash[:tipo_asiento]
      @concesiondirect.espectro.titulo_habilitante.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @concesiondirect.espectro.titulo_habilitante.asiento.numero_resolucion = hash[:numero_resolucion]
      @concesiondirect.espectro.titulo_habilitante.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @concesiondirect.espectro.titulo_habilitante.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @concesiondirect.espectro.titulo_habilitante.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @concesiondirect.espectro.titulo_habilitante.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @concesiondirect.espectro.titulo_habilitante.asiento.nombre_operador = hash[:nombre_operador]
      @concesiondirect.espectro.titulo_habilitante.asiento.identificacion_operador = hash[:identificacion_operador]
      @concesiondirect.espectro.titulo_habilitante.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @concesiondirect.espectro.titulo_habilitante.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @concesiondirect.espectro.titulo_habilitante.asiento.usuario = hash[:usuario]
      @concesiondirect.espectro.titulo_habilitante.asiento.enlace_documento = hash[:enlace_documento]
      @concesiondirect.espectro.titulo_habilitante.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @concesiondirect.espectro.titulo_habilitante.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @concesiondirect.espectro.titulo_habilitante.asiento.vigencia2 = hash[:vigencia2]
      @concesiondirect.espectro.titulo_habilitante.asiento.acto_id = hash[:acto_id]
      @concesiondirect.espectro.titulo_habilitante.asiento.acto_type = "TituloHabilitante"

    end

end
