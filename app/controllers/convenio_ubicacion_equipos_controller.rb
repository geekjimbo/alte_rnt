class ConvenioUbicacionEquiposController < ApplicationController

  PER_PAGE = 10

  def index
    @convenio_ubicacion_equipos = ConvenioUbicacionEquipo.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @convenio_ubicacion_equipo = ConvenioUbicacionEquipo.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @convenio_ubicacion_equipo = ConvenioUbicacionEquipo.new
    @asiento = @convenio_ubicacion_equipo.build_asiento

    @anatext_asiento = check_for_anatext @convenio_ubicacion_equipo.asiento
    @convenio_ubicacion_equipo.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @convenio_ubicacion_equipo.asiento.tipo_asiento = "AS"
    @convenio_ubicacion_equipo.asiento.tipo_inscripcion = "Asiento Nuevo"
    @convenio_ubicacion_equipo.operadores_convenio_ubicacion_equipos.new
    # build childs
    #@convenio_ubicacion_equipo.servicio_habilitado.new
  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
    @convenio_ubicacion_equipo = ConvenioUbicacionEquipo.find(params[:id])
    @asiento = @convenio_ubicacion_equipo.asiento
    @convenio_ubicacion_equipo.asiento.tipo_asiento = "ED"
    #@convenio_ubicacion_equipo.asiento.tipo_inscripcion = "Modificación de Asiento"

    #@servicio_habilitado = @convenio_ubicacion_equipo.servicio_habilitado.first
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@convenio_ubicacion_equipo = ConvenioUbicacionEquipo.new(convenio_ubicacion_equipo_params)

    if !is_asiento_nil? 
      if @convenio_ubicacion_equipo.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Convenio Ubicación Equipo creada exitosamente"
        redirect_to asientos_path
        #redirect_to convenio_ubicacion_equipos_url
      else
        flash.now[:danger] = 'Convenio Ubicación Equipo no creada, hay errores que corregir' 
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
    ConvenioUbicacionEquipo.find(params[:id]).destroy
    flash.now[:success] = "Convenio Ubicación Equipo borrada"
    redirect_to asientos_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_convenio_ubicacion_equipo
      @convenio_ubicacion_equipo = ConvenioUbicacionEquipo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def convenio_ubicacion_equipo_params
        unless params[:convenio_ubicacion_equipo].empty? 
          params.require(:convenio_ubicacion_equipo).permit(:titulo_convenio, :nota, :fecha_vencimiento, :numero_anexos, :adendas, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ], operadores_convenio_ubicacion_equipos_attributes: [:operador_regulados_id, :nombre_operador, :identificacion_operdor, :nombre_representante_legal, :cedula_representante_legal])
        end
    end
    
    def is_asiento_nil?
      #check_stack_for_nil
      #@convenio_ubicacion_equipoasiento.nil?
      @convenio_ubicacion_equipo.nil?
    end

    def set_asientos_fields
      rn = params[:convenio_ubicacion_equipo][:asiento_attributes]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          rn[:fecha_solicitud] = Time.new
        end

        rn[:acto_inscribible] = "convenio_ubicacion_equipo"
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

    def clonar
      # clonar el convenio_ubicacion_equipo y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto convenio_ubicacion_equipo
      neutro = params[:convenio_ubicacion_equipo]
      convenio_ubicacion_equipo = ConvenioUbicacionEquipo.new
      neutro.each do |key, val|
        unless key.include? "_attributes" 
          convenio_ubicacion_equipo[key] = val if key != "id"
        end
      end if neutro

      #copiar detalle operadores 
      operadores_convenio_ubicacion_equipos = neutro[:operadores_convenio_ubicacion_equipos_attributes]
      unless operadores_convenio_ubicacion_equipos.nil? 
        operadores_convenio_ubicacion_equipos.each do |sn|
          operador = convenio_ubicacion_equipo.operadores_convenio_ubicacion_equipos.new
          sn[1].each do |key, val|
            operador[key] = val if key != "id"
          end
        end
      end

      asiento = convenio_ubicacion_equipo.build_asiento
      neutro = params[:convenio_ubicacion_equipo][:asiento_attributes]
      #copiar objeto asiento
      neutro.each do |key, val|
        asiento[key] = val if key != "id"
      end

      return convenio_ubicacion_equipo
    end

    def clonar_objetos

      convenio_ubicacion_equipo = clonar
      obj = ConvenioUbicacionEquipo.find(params[:id])
      if  params[:convenio_ubicacion_equipo][:asiento_attributes][:tipo_asiento]== "MD"
        convenio_ubicacion_equipo.asiento.num_asiento_original = obj.asiento.num_asiento
        convenio_ubicacion_equipo.asiento.num_asiento = obtener_numero_asiento("MD")
        convenio_ubicacion_equipo.asiento.tipo_asiento = "MD"
        convenio_ubicacion_equipo.asiento.tipo_inscripcion = "Modificación de Asiento"
        convenio_ubicacion_equipo.asiento.acto_type = "ConvenioUbicacionEquipo"
        convenio_ubicacion_equipo.asiento.acto_inscribible = obj.asiento.acto_inscribible
        convenio_ubicacion_equipo.asiento.fecha_solicitud = obj.asiento.fecha_solicitud
      else
        convenio_ubicacion_equipo.asiento.num_asiento_original = obj.asiento.num_asiento_original
        convenio_ubicacion_equipo.asiento.num_asiento = obj.asiento.num_asiento
        convenio_ubicacion_equipo.asiento.tipo_asiento = obj.asiento.tipo_asiento
        convenio_ubicacion_equipo.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        convenio_ubicacion_equipo.asiento.acto_type = obj.asiento.acto_type
        convenio_ubicacion_equipo.asiento.acto_inscribible = obj.asiento.acto_inscribible
        convenio_ubicacion_equipo.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        # borrar objetos
        obj.asiento.destroy
        obj.destroy
      end

      #grabar objeto
      @convenio_ubicacion_equipo = convenio_ubicacion_equipo
      if @convenio_ubicacion_equipo.save
        flash.now[:success] = "Convenio Ubicación Equipo actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Convenio Ubicación Equipo no modificado, hay errores que corregir' 
        render :edit
      end
    end

    def check_stack_for_nil
      #build stack up
      @convenio_ubicacion_equipo if @convenio_ubicacion_equipo.nil? 
      @convenio_ubicacion_equipo.build_asiento if @convenio_ubicacion_equipo.asiento.nil?
    end

    def create_ancestors_from_hash
      @convenio_ubicacion_equipo = ConvenioUbicacionEquipo.new(convenio_ubicacion_equipo_params) if action_name == "create"
      @convenio_ubicacion_equipo = ConvenioUbicacionEquipo.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:convenio_ubicacion_equipo][:asiento_attributes]
      @convenio_ubicacion_equipo.asiento.acto_inscribible = hash[:acto_inscribible]
      @convenio_ubicacion_equipo.asiento.tipo_asiento = hash[:tipo_asiento]
      @convenio_ubicacion_equipo.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @convenio_ubicacion_equipo.asiento.numero_resolucion = hash[:numero_resolucion]
      @convenio_ubicacion_equipo.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @convenio_ubicacion_equipo.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @convenio_ubicacion_equipo.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @convenio_ubicacion_equipo.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @convenio_ubicacion_equipo.asiento.nombre_operador = hash[:nombre_operador]
      @convenio_ubicacion_equipo.asiento.identificacion_operador = hash[:identificacion_operador]
      @convenio_ubicacion_equipo.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @convenio_ubicacion_equipo.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @convenio_ubicacion_equipo.asiento.usuario = hash[:usuario]
      @convenio_ubicacion_equipo.asiento.enlace_documento = hash[:enlace_documento]
      @convenio_ubicacion_equipo.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @convenio_ubicacion_equipo.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @convenio_ubicacion_equipo.asiento.vigencia2 = hash[:vigencia2]
      @convenio_ubicacion_equipo.asiento.acto_id = hash[:acto_id]
      @convenio_ubicacion_equipo.asiento.acto_type = "ConvenioUbicacionEquipo"

    end

end
