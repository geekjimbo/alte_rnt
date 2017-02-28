class ResolucionUbicacionEquiposController < ApplicationController

  PER_PAGE = 10

  def index
    @resolucionubicacionequipos = ResolucionUbicacionEquipo.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @resolucionubicacionequipo = ResolucionUbicacionEquipo.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @resolucionubicacionequipo = ResolucionUbicacionEquipo.new
    @resolucionubicacionequipo.build_asiento

    @anatext_asiento = check_for_anatext @resolucionubicacionequipo.asiento
    @resolucionubicacionequipo.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @resolucionubicacionequipo.asiento
    @resolucionubicacionequipo.asiento.tipo_asiento = "AS"
    @resolucionubicacionequipo.asiento.tipo_inscripcion = "Asiento Nuevo"
    @resolucionubicacionequipo.operadores_resolucion_ubicacion_equipos.new
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @resolucionubicacionequipo = ResolucionUbicacionEquipo.find(params[:id])
    @asiento = @resolucionubicacionequipo.asiento
    @resolucionubicacionequipo.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @resolucionubicacionequipo = ResolucionUbicacionEquipo.new(resolucion_ubicacion_equipo_params)

    if !is_asiento_nil? 
      if @resolucionubicacionequipo.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Resolución Ubicación Equipo creado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Resolución Ubicación Equipo no creado, hay errores que corregir' 
        @resolucionubicacionequipo.build_asiento
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
    ResolucionUbicacionEquipo.find(params[:id]).destroy
    flash.now[:success] = "resolución ubicacion equipo borrada"
    redirect_to resolucion_ubicacion_equipos_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resolucion_ubicacion_equipo
      @resolucionubicacionequipo = ResolucionUbicacionEquipo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resolucion_ubicacion_equipo_params
        unless params[:resolucion_ubicacion_equipo].empty? 
          params.require(:resolucion_ubicacion_equipo).permit(:fecha_vigencia, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ], operadores_resolucion_ubicacion_equipos_attributes: [:operador_regulados_id, :nombre_operador, :identificacion_operador, :nombre_representante_legal, :cedula_representante_legal])
        end
    end
    
    def is_asiento_nil?
      @resolucionubicacionequipo.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:resolucion_ubicacion_equipo]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:acto_inscribible] = "ResolucionUbicacionEquipo"
        if rn[:asiento_attributes][:nombre_operador].blank? or rn[:asiento_attributes][:identificacion_operador].blank? and !rn[:asiento_attributes][:operadorregulado_id].blank?
          @operador = OperadorRegulado.find(rn[:asiento_attributes][:operadorregulado_id])
          rn[:asiento_attributes][:nombre_operador] = @operador.nombre
          rn[:asiento_attributes][:identificacion_operador] = @operador.identificacion
          rn[:asiento_attributes][:nombre_representante_legal] = @operador.nombre_representante_legal
          rn[:asiento_attributes][:cedula_representante_legal] = @operador.cedula_representante_legal
        end
        rn[:asiento_attributes][:usuario] = current_user.id.to_s + "-" + current_user.email

        if action_name == 'update'
          clonar_objetos
        end
      end

    end

    def clonar
      neutro = params[:resolucion_ubicacion_equipo]
      asiento = Asiento.new
      tramite = ResolucionUbicacionEquipo.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key.include?("_attributes")
          tramite[key] = val if key != "id"
        end
      end

      #copiar detalle operadores 
      operadores_resolucion_ubicacion_equipos = params[:resolucion_ubicacion_equipo][:operadores_resolucion_ubicacion_equipos_attributes]
      unless operadores_resolucion_ubicacion_equipos.nil? 
        operadores_resolucion_ubicacion_equipos.each do |sn|
          operador = tramite.operadores_resolucion_ubicacion_equipos.new
          sn[1].each do |key, val|
            operador[key] = val if key != "id"
          end
        end
      end

      neutro = params[:resolucion_ubicacion_equipo][:asiento_attributes]
      #copiar objeto hijo existente
      neutro.each do |key, val|
        asiento[key] = val if key != "id"
      end

      #crear stub del hijo en el padre
      tramite.build_asiento

      #copiar valores al hijo
      asiento.attributes.each do |key,val|
        tramite.asiento[key] = asiento[key] if key != "id"
      end
      return tramite
    end

    def clonar_objetos

      tramite = clonar
      # tercambiar llaves
      obj = ResolucionUbicacionEquipo.find(params[:id])

      if  params[:resolucion_ubicacion_equipo][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "ResolucionUbicacionEquipo"
        tramite.asiento.acto_inscribible = obj.asiento.acto_inscribible
        tramite.asiento.fecha_solicitud = obj.asiento.fecha_solicitud
      else
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento_original
        tramite.asiento.num_asiento = obj.asiento.num_asiento
        tramite.asiento.tipo_asiento = obj.asiento.tipo_asiento
        tramite.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        tramite.asiento.acto_type = obj.asiento.acto_type
        tramite.asiento.acto_inscribible = obj.asiento.acto_inscribible
        tramite.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        #borrar objetos
        obj.asiento.destroy
        obj.destroy
      end
      
      @resolucionubicacionequipo = tramite

      if @resolucionubicacionequipo.save
        flash.now[:success] = "Resolución Ubicación Equipo actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Resolución Ubicación Equipo no modificado, hay errores que corregir' 
        render :edit
      end
    end


end
