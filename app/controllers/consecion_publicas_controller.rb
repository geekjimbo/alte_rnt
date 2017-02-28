class ConsecionPublicasController < ApplicationController
  
  PER_PAGE = 10

  def index
    @consecionpublicas = ConsecionPublica.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @consecionpublica = ConsecionPublica.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @consecionpublica = ConsecionPublica.new

    #build stack up
    @consecionpublica.build_espectro
    @consecionpublica.espectro.build_titulo_habilitante
    @consecionpublica.espectro.titulo_habilitante.build_asiento

    @anatext_asiento = check_for_anatext @consecionpublica.espectro.titulo_habilitante.asiento
    @consecionpublica.espectro.titulo_habilitante.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @consecionpublica.espectro.titulo_habilitante.asiento.tipo_asiento = "AS"
    @consecionpublica.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Asiento Nuevo"

    # load anatext if any
    #@consecionpublica.espectro.titulo_habilitante.asiento = check_for_anatext @consecionpublica.espectro.titulo_habilitante.asiento

    @espectro = @consecionpublica.espectro
    @titulo_habilitante = @consecionpublica.espectro.titulo_habilitante
    @asiento = @consecionpublica.espectro.titulo_habilitante.asiento

    # build childs
    @consecionpublica.espectro.frecuencia_espectro.new
    #@consecionpublica.espectro.frecuencia_espectro.first.zona.new
    @consecionpublica.espectro.titulo_habilitante.servicio_habilitados.new
    @frecuencia_espectro = @consecionpublica.espectro.frecuencia_espectro.first
    #@zona = @consecionpublica.espectro.frecuencia_espectro.first.zona.first
    @servicio_habilitado = @consecionpublica.espectro.titulo_habilitante.servicio_habilitados.first
  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
    @consecionpublica = ConsecionPublica.find(params[:id])

    # stack up
    @espectro = @consecionpublica.espectro
    @titulo_habilitante = @consecionpublica.espectro.titulo_habilitante
    @asiento = @consecionpublica.espectro.titulo_habilitante.asiento
    @consecionpublica.espectro.titulo_habilitante.asiento.tipo_asiento = "ED"
    #@consecionpublica.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Modificación de Asiento"

    # childs
    @consecionpublica.espectro.frecuencia_espectro.new if @consecionpublica.espectro.frecuencia_espectro.first.nil?
    @consecionpublica.espectro.frecuencia_espectro.first.zona.new if @consecionpublica.espectro.frecuencia_espectro.first.zona.first.nil?
    @consecionpublica.espectro.titulo_habilitante.servicio_habilitados.new if @consecionpublica.espectro.titulo_habilitante.servicio_habilitados.nil?

    @frecuencia_espectro = @consecionpublica.espectro.frecuencia_espectro.all 
    @zona = @consecionpublica.espectro.frecuencia_espectro.first.zona.all 
    @servicio_habilitado = @consecionpublica.espectro.titulo_habilitante.servicio_habilitados.all   
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@consecionpublica = concesiondirect.new(concesiondirect_params)

    if !is_asiento_nil? 
      if @consecionpublica.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Conseción Directa creada exitosamente"
        redirect_to asientos_path
        #redirect_to consecionpublicas_url
      else
        flash.now[:danger] = 'Conseción Directa no creada, hay errores que corregir' 
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
    consecionpublica.find(params[:id]).destroy
    flash.now[:success] = "Conseción Pública borrada"
    redirect_to consecionpublicas_url
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_consecion_publica
      @consecion_publica = ConsecionPublica.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def consecionpublica_params
        unless params[:consecion_publica].empty? 
          params.require(:consecion_publica).permit(:id, :fecha_vencimiento, :tipo_red, :fecha_publicacion, :numero_publicacion, :contrato_concesion, :fecha_emision, :numero_notificacion_refrendo, :fecha_notificacion_refrendo, espectro_attributes: [:id, :clasificacion_uso_espectro, :titulo_id, [frecuencia_espectro_attributes: [:tipo_frecuencia, :desde, :hasta, :tx_desde, :tx_hasta, :rx_desde, :rx_hasta, :unidad_desde, :unidad_hasta, :espectro_id, [zona_attributes: [:tipo_zona, :descripcion_zona, :frecuenciaespectro_id, :provincia, :canton, :distrito, :nota]]]], :titulo_type, [titulo_habilitante_attributes: [:id, :numero_titulo, :fecha_titulo, :fecha_notificacion, :causal_finalizacion, :espectrable_id, :espectrable_type, [servicio_habilitados_attributes: [:sciservicio_id, :titulo_habilitante_id, :nota, :servicio]] , asiento: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ]]]])
        end
    end
    
    def is_asiento_nil?
      #check_stack_for_nil
      #@consecionpublica.espectro.titulo_habilitante.asiento.nil?
      @consecionpublica.espectro.titulo_habilitante.nil?
    end

    def set_asientos_fields
      rn = params[:consecion_publica][:espectro_attributes][:asiento]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          rn[:fecha_solicitud] = Time.now
        end

        rn[:acto_inscribible] = "consecionpublica"
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
      # clonar el consecionpublica y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto consecionpublica
      my_hash = params[:consecion_publica]
      consecionpublica = deep_copy(ConsecionPublica, my_hash, params[:id])

      #grabar objeto
      @consecionpublica =  consecionpublica

      if @consecionpublica.save
        @consecutivo.save if !@consecutivo.nil?
        flash.now[:success] = "Conseción Pública actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Conseción Pública no modificado, hay errores que corregir' 
        render :edit
      end
    end

    def check_stack_for_nil
      #build stack up
      @consecionpublica.build_espectro if @consecionpublica.espectro.nil? 
      @consecionpublica.espectro.build_titulo_habilitante if @consecionpublica.espectro.titulo_habilitante.nil?
      @consecionpublica.espectro.titulo_habilitante.build_asiento if @consecionpublica.espectro.titulo_habilitante.asiento.nil?
      @consecionpublica.espectro.frecuencia_espectro.new if @consecionpublica.espectro.frecuencia_espectro.first.nil?
      #@consecionpublica.espectro.frecuencia_espectro.first.zona.new if !@consecionpublica.espectro.frecuencia_espectro.first.zona.any?
      @consecionpublica.espectro.titulo_habilitante.servicio_habilitados.new if !@consecionpublica.espectro.titulo_habilitante.servicio_habilitados.any?
    end

    def create_ancestors_from_hash
      @consecionpublica = ConsecionPublica.new(consecionpublica_params) if action_name == "create"
      @consecionpublica = ConsecionPublica.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:consecion_publica][:espectro_attributes][:titulo_habilitante_attributes]

      # clonar titulo_habilitante
      @consecionpublica.espectro.titulo_habilitante.numero_titulo = hash[:numero_titulo]
      @consecionpublica.espectro.titulo_habilitante.fecha_titulo = hash[:fecha_titulo]
      @consecionpublica.espectro.titulo_habilitante.fecha_notificacion = hash[:fecha_notificacion]
      @consecionpublica.espectro.titulo_habilitante.causal_finalizacion = hash[:causal_finalizacion]
      @consecionpublica.espectro.titulo_habilitante.espectrable_id = hash[:espectrable_id]
      @consecionpublica.espectro.titulo_habilitante.espectrable_type = "Espectro"

      hash = params[:consecion_publica][:espectro_attributes][:asiento]
      @consecionpublica.espectro.titulo_habilitante.asiento.num_asiento = hash[:num_asiento] if action_name == "create"
      @consecionpublica.espectro.titulo_habilitante.asiento.num_asiento_original = hash[:num_asiento_original]
      @consecionpublica.espectro.titulo_habilitante.asiento.acto_inscribible = hash[:acto_inscribible]
      @consecionpublica.espectro.titulo_habilitante.asiento.tipo_asiento = hash[:tipo_asiento]
      @consecionpublica.espectro.titulo_habilitante.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @consecionpublica.espectro.titulo_habilitante.asiento.numero_resolucion = hash[:numero_resolucion]
      @consecionpublica.espectro.titulo_habilitante.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @consecionpublica.espectro.titulo_habilitante.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @consecionpublica.espectro.titulo_habilitante.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @consecionpublica.espectro.titulo_habilitante.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @consecionpublica.espectro.titulo_habilitante.asiento.nombre_operador = hash[:nombre_operador]
      @consecionpublica.espectro.titulo_habilitante.asiento.identificacion_operador = hash[:identificacion_operador]
      @consecionpublica.espectro.titulo_habilitante.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @consecionpublica.espectro.titulo_habilitante.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @consecionpublica.espectro.titulo_habilitante.asiento.usuario = hash[:usuario]
      @consecionpublica.espectro.titulo_habilitante.asiento.enlace_documento = hash[:enlace_documento]
      @consecionpublica.espectro.titulo_habilitante.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @consecionpublica.espectro.titulo_habilitante.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @consecionpublica.espectro.titulo_habilitante.asiento.vigencia2 = hash[:vigencia2]
      @consecionpublica.espectro.titulo_habilitante.asiento.acto_id = hash[:acto_id]
      @consecionpublica.espectro.titulo_habilitante.asiento.acto_type = "TituloHabilitante"

    end

end
