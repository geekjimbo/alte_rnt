class ConsecionAnteriorsController < ApplicationController
  
  PER_PAGE = 10

  def index
    @consesionanteriors = ConsecionAnteriors.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @consesionanterior = ConsecionAnteriors.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @consesionanterior = ConsecionAnterior.new

    #build stack up
    @consesionanterior.build_espectro
    @consesionanterior.espectro.build_titulo_habilitante
    @consesionanterior.espectro.titulo_habilitante.build_asiento

    @anatext_asiento = check_for_anatext @consesionanterior.espectro.titulo_habilitante.asiento
    @consesionanterior.espectro.titulo_habilitante.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @consesionanterior.espectro.titulo_habilitante.asiento.tipo_asiento = "AS"
    @consesionanterior.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Asiento Nuevo"
    
    # load anatext if any
    #@consesionanterior.espectro.titulo_habilitante.asiento = check_for_anatext @consesionanterior.espectro.titulo_habilitante.asiento

    @espectro = @consesionanterior.espectro
    @titulo_habilitante = @consesionanterior.espectro.titulo_habilitante
    @asiento = @consesionanterior.espectro.titulo_habilitante.asiento

    # build childs
    @consesionanterior.espectro.frecuencia_espectro.new
    #@consesionanterior.espectro.frecuencia_espectro.first.zona.new
    @consesionanterior.espectro.titulo_habilitante.servicio_habilitados.new
    @frecuencia_espectro = @consesionanterior.espectro.frecuencia_espectro.first
    #@zona = @consesionanterior.espectro.frecuencia_espectro.first.zona.first
    @servicio_habilitado = @consesionanterior.espectro.titulo_habilitante.servicio_habilitados.first
  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
    @consesionanterior = ConsecionAnterior.find(params[:id])

    # stack up
    @espectro = @consesionanterior.espectro
    @titulo_habilitante = @consesionanterior.espectro.titulo_habilitante
    @asiento = @consesionanterior.espectro.titulo_habilitante.asiento

    @consesionanterior.espectro.titulo_habilitante.asiento.tipo_asiento = "ED"
    #@consesionanterior.espectro.titulo_habilitante.asiento.tipo_inscripcion = "Modificación de Asiento"
    # childs
    @consesionanterior.espectro.frecuencia_espectro.new if @consesionanterior.espectro.frecuencia_espectro.first.nil?
    @consesionanterior.espectro.frecuencia_espectro.first.zona.new if @consesionanterior.espectro.frecuencia_espectro.first.zona.first.nil?
    @consesionanterior.espectro.titulo_habilitante.servicio_habilitados.new if @consesionanterior.espectro.titulo_habilitante.servicio_habilitados.nil?

    @frecuencia_espectro = @consesionanterior.espectro.frecuencia_espectro.first 
    @zona = @consesionanterior.espectro.frecuencia_espectro.first.zona.first
    @servicio_habilitado = @consesionanterior.espectro.titulo_habilitante.servicio_habilitados.first   
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@consesionanterior = consesionanterior.new(consesionanterior_params)

    if !is_asiento_nil? 
      if @consesionanterior.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Conseción Anterior a la Ley de la SUTEL creada exitosamente"
        redirect_to asientos_path
        #redirect_to consesionanteriors_url
      else
        flash.now[:danger] = 'Conseción Anterior a la Ley de la SUTEL no creada, hay errores que corregir' 
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
    consesionanterior.find(params[:id]).destroy
    flash.now[:success] = "Conseción Anterior al a Ley de la SUTEL borrada"
    redirect_to consesionanteriors_url
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_consecion_anterior
      @consecion_anterior = ConsecionAnterior.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def consesionanterior_params
        unless params[:consecion_anterior].empty? 
          params.require(:consecion_anterior).permit(:id, :numero_adecuacion_poder_ejecutivo, :fecha_adecuacion_poder_ejecutivo ,espectro_attributes: [:id, :clasificacion_uso_espectro, :titulo_id, [frecuencia_espectro_attributes: [:tipo_frecuencia, :desde, :hasta, :tx_desde, :tx_hasta, :rx_desde, :rx_hasta, :unidad_desde, :unidad_hasta, :espectro_id, [zona_attributes: [:tipo_zona, :descripcion_zona, :frecuenciaespectro_id, :provincia, :canton, :distrito, :nota]]]] ,:titulo_type, [titulo_habilitante_attributes: [:id, :numero_titulo, :fecha_titulo, :fecha_notificacion, :causal_finalizacion, :espectrable_id, :espectrable_type, [servicio_habilitados_attributes: [:sciservicio_id, :titulo_habilitante_id, :nota, :servicio]] , asiento: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ]]]])
        end
    end
    
    def is_asiento_nil?
      #check_stack_for_nil
      #@consesionanterior.espectro.titulo_habilitante.asiento.nil?
      @consesionanterior.espectro.titulo_habilitante.nil?
    end

    def set_asientos_fields
      rn = params[:consecion_anterior][:espectro_attributes][:asiento]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          #rn[:fecha_solicitud] = Time.now
        end
        
        rn[:acto_inscribible] = "ConsesionAnterior"
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
      # clonar el consesionanterior y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto consesionanterior
      my_hash = params[:consecion_anterior]
      consesionanterior = deep_copy(ConsecionAnterior, my_hash, params[:id])
      @consesionanterior = consesionanterior

      #grabar objeto
      if @consesionanterior.save
        @consecutivo.save if !@consecutivo.nil?
        flash.now[:success] = "Conseción Anterior a la Ley de la SUTEL actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Conseción Anterior a la Ley de la SUTEL no modificado, hay errores que corregir' 
        render :edit
      end
    end

    def handle_servicios
      n = Nested.new
      my_hash = params[:consecion_anterior][:espectro_attributes][:titulo_habilitante_attributes][:servicio_habilitados_attributes]
      n.servicios :action => :update, :titulo_habilitante_id => @autorizacion.titulo_habilitante.id, :hash_fresh => my_hash
    end

    def check_stack_for_nil
      #build stack up
      @consesionanterior.build_espectro if @consesionanterior.espectro.nil? 
      @consesionanterior.espectro.build_titulo_habilitante if @consesionanterior.espectro.titulo_habilitante.nil?
      @consesionanterior.espectro.titulo_habilitante.build_asiento if @consesionanterior.espectro.titulo_habilitante.asiento.nil?
      @consesionanterior.espectro.frecuencia_espectro.new if @consesionanterior.espectro.frecuencia_espectro.first.nil?
      #@consesionanterior.espectro.frecuencia_espectro.first.zona.new if !@consesionanterior.espectro.frecuencia_espectro.first.zona.any?
      @consesionanterior.espectro.titulo_habilitante.servicio_habilitados.new if !@consesionanterior.espectro.titulo_habilitante.servicio_habilitados.any?
    end

    def create_ancestors_from_hash
      @consesionanterior = ConsecionAnterior.new(consesionanterior_params) if action_name == "create"
      @consesionanterior = ConsecionAnterior.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:consecion_anterior][:espectro_attributes][:titulo_habilitante_attributes]

      # clonar titulo_habilitante
      @consesionanterior.espectro.titulo_habilitante.numero_titulo = hash[:numero_titulo]
      @consesionanterior.espectro.titulo_habilitante.fecha_titulo = hash[:fecha_titulo]
      @consesionanterior.espectro.titulo_habilitante.fecha_notificacion = hash[:fecha_notificacion]
      @consesionanterior.espectro.titulo_habilitante.causal_finalizacion = hash[:causal_finalizacion]
      @consesionanterior.espectro.titulo_habilitante.espectrable_id = hash[:espectrable_id]
      @consesionanterior.espectro.titulo_habilitante.espectrable_type = "Espectro"

      hash = params[:consecion_anterior][:espectro_attributes][:asiento]
      @consesionanterior.espectro.titulo_habilitante.asiento.num_asiento = hash[:num_asiento] if action_name == "create"
      @consesionanterior.espectro.titulo_habilitante.asiento.num_asiento_original = hash[:num_asiento_original]
      @consesionanterior.espectro.titulo_habilitante.asiento.acto_inscribible = hash[:acto_inscribible]
      @consesionanterior.espectro.titulo_habilitante.asiento.tipo_asiento = hash[:tipo_asiento]
      @consesionanterior.espectro.titulo_habilitante.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @consesionanterior.espectro.titulo_habilitante.asiento.numero_resolucion = hash[:numero_resolucion]
      @consesionanterior.espectro.titulo_habilitante.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @consesionanterior.espectro.titulo_habilitante.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @consesionanterior.espectro.titulo_habilitante.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @consesionanterior.espectro.titulo_habilitante.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @consesionanterior.espectro.titulo_habilitante.asiento.nombre_operador = hash[:nombre_operador]
      @consesionanterior.espectro.titulo_habilitante.asiento.identificacion_operador = hash[:identificacion_operador]
      @consesionanterior.espectro.titulo_habilitante.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @consesionanterior.espectro.titulo_habilitante.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @consesionanterior.espectro.titulo_habilitante.asiento.usuario = hash[:usuario]
      @consesionanterior.espectro.titulo_habilitante.asiento.enlace_documento = hash[:enlace_documento]
      @consesionanterior.espectro.titulo_habilitante.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @consesionanterior.espectro.titulo_habilitante.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @consesionanterior.espectro.titulo_habilitante.asiento.vigencia2 = hash[:vigencia2]
      @consesionanterior.espectro.titulo_habilitante.asiento.acto_id = hash[:acto_id]
      @consesionanterior.espectro.titulo_habilitante.asiento.acto_type = "TituloHabilitante"

    end

end
