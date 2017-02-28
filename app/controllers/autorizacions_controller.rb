require 'nested_servicios'

class AutorizacionsController < ApplicationController
  
  PER_PAGE = 10

  def index
    @autorizacions = Autorizacion.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @autorizacion = Autorizacion.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @autorizacion = Autorizacion.new

    #build stack up
    @autorizacion.build_titulo_habilitante
    @autorizacion.titulo_habilitante.build_asiento
    
    # load anatext if any
    @anatext_asiento = check_for_anatext @autorizacion.titulo_habilitante.asiento
    @autorizacion.titulo_habilitante.asiento = @anatext_asiento if !@anatext_asiento.nil? 

    @titulo_habilitante = @autorizacion.titulo_habilitante
    @asiento = @autorizacion.titulo_habilitante.asiento
    @autorizacion.titulo_habilitante.asiento.tipo_asiento = "AS"
    @autorizacion.titulo_habilitante.asiento.tipo_inscripcion = "Asiento Nuevo"

    # build childs
    @autorizacion.titulo_habilitante.servicio_habilitados.new
    #@servicio_habilitado = @autorizacion.titulo_habilitante.servicio_habilitados.first
  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
    @autorizacion = Autorizacion.find(params[:id])
    @autorizacion.titulo_habilitante.asiento.tipo_asiento = "ED"
    #@autorizacion.titulo_habilitante.asiento.tipo_inscripcion = "Modificación de Asiento"

    # stack up
    @titulo_habilitante = @autorizacion.titulo_habilitante
    @asiento = @autorizacion.titulo_habilitante.asiento

    @servicio_habilitado = @autorizacion.titulo_habilitante.servicio_habilitados.first
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@autorizacion = autorizacion.new(autorizacion_params)

    if !is_asiento_nil? 
      if @autorizacion.save
        @consecutivo.save
        #handle_servicios
        flash.now[:success] = "Autorización creada exitosamente"
        redirect_to asientos_path
        #redirect_to autorizacions_url
      else
        flash.now[:danger] = 'Autorización no creada, hay errores que corregir' 
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
    autorizacion.find(params[:id]).destroy
    flash.now[:success] = "Autorización borrada"
    redirect_to autorizacions_url
  end

  private
    def set_autorizacion
      @autorizacion = Autorizacion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def autorizacion_params
        unless params[:autorizacion].empty? 
          params.require(:autorizacion).permit(:id, :fecha_vencimiento, :numero_publicacion_gaceta, :fecha_publicacion_gaceta, :tipo_red, :titulo_type, zona_attributes: [:tipo_zona, :descripcion_zona, :autorizacions_id, :provincia, :canton, :distrito, :nota], titulo_habilitante_attributes: [:id, :numero_titulo, :fecha_titulo, :fecha_notificacion, :causal_finalizacion, :espectrable_id, :espectrable_type, [servicio_habilitados_attributes: [:servicio, :id, :sciservicio_id, :nota]] , asiento: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ]]) 
        end
    end
    
    def is_asiento_nil?
      #check_stack_for_nil
      #@autorizaciontitulo_habilitante.asiento.nil?
      @autorizacion.titulo_habilitante.nil?
    end

    def set_asientos_fields
      rn = params[:autorizacion][:asiento]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          rn[:fecha_solicitud] = Time.now
        end

        rn[:acto_inscribible] = "autorizacion"
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

    def borrar_objetos(child)
      unless child.nil? 
        child.each do |c|
          c.destroy
        end
      end
    end

    def clonar_objetos
      # clonar el autorizacion y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto autorizacion
      my_hash = params[:autorizacion]
      autorizacion = autorizacion_deep_copy(Autorizacion, my_hash, params[:id])

      @autorizacion = autorizacion
      #grabar objeto
      if @autorizacion.save
        @consecutivo.save if !@consecutivo.nil?
        #handle_servicios
        flash.now[:success] = "Autorización actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Autorización no modificado, hay errores que corregir' 
        render :edit
      end

    end

    def check_stack_for_nil
      #build stack up
      @autorizacion if @autorizacion.nil? 
      @autorizacion.build_titulo_habilitante if @autorizacion.titulo_habilitante.nil?
      @autorizacion.titulo_habilitante.build_asiento if @autorizacion.titulo_habilitante.asiento.nil?
      @autorizacion.titulo_habilitante.servicio_habilitados.new if !@autorizacion.titulo_habilitante.servicio_habilitados.any?
    end

    def create_ancestors_from_hash
      @autorizacion = Autorizacion.new(autorizacion_params) if action_name == "create"
      @autorizacion = Autorizacion.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:autorizacion][:titulo_habilitante_attributes]

      # clonar titulo_habilitante
      @autorizacion.titulo_habilitante.numero_titulo = hash[:numero_titulo]
      @autorizacion.titulo_habilitante.fecha_titulo = hash[:fecha_titulo]
      @autorizacion.titulo_habilitante.fecha_notificacion = hash[:fecha_notificacion]
      @autorizacion.titulo_habilitante.causal_finalizacion = hash[:causal_finalizacion]
      @autorizacion.titulo_habilitante.espectrable_id = hash[:espectrable_id]
      @autorizacion.titulo_habilitante.espectrable_type = "Autorizacion"

      hash = params[:autorizacion][:asiento]
      @autorizacion.titulo_habilitante.asiento.num_asiento = hash[:num_asiento] if action_name == "create"
      @autorizacion.titulo_habilitante.asiento.num_asiento_original = hash[:num_asiento_original]
      @autorizacion.titulo_habilitante.asiento.acto_inscribible = hash[:acto_inscribible]
      @autorizacion.titulo_habilitante.asiento.tipo_asiento = hash[:tipo_asiento]
      @autorizacion.titulo_habilitante.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @autorizacion.titulo_habilitante.asiento.numero_resolucion = hash[:numero_resolucion]
      @autorizacion.titulo_habilitante.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @autorizacion.titulo_habilitante.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @autorizacion.titulo_habilitante.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @autorizacion.titulo_habilitante.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @autorizacion.titulo_habilitante.asiento.nombre_operador = hash[:nombre_operador]
      @autorizacion.titulo_habilitante.asiento.identificacion_operador = hash[:identificacion_operador]
      @autorizacion.titulo_habilitante.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @autorizacion.titulo_habilitante.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @autorizacion.titulo_habilitante.asiento.usuario = hash[:usuario]
      @autorizacion.titulo_habilitante.asiento.enlace_documento = hash[:enlace_documento]
      @autorizacion.titulo_habilitante.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @autorizacion.titulo_habilitante.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @autorizacion.titulo_habilitante.asiento.vigencia2 = hash[:vigencia2]
      @autorizacion.titulo_habilitante.asiento.acto_id = hash[:acto_id]
      @autorizacion.titulo_habilitante.asiento.acto_type = "TituloHabilitante"
    end

end
