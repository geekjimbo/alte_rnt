class OrdenAccesoInterconexionsController < ApplicationController

  PER_PAGE = 10

  def index
    @ordenaccesointerconexions = OrdenAccesoInterconexion.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @ordenaccesointerconexion = OrdenAccesoInterconexion.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @ordenaccesointerconexion = OrdenAccesoInterconexion.new
    @ordenaccesointerconexion.build_asiento
    @asiento = @ordenaccesointerconexion.asiento

    @anatext_asiento = check_for_anatext @ordenaccesointerconexion.asiento
    @ordenaccesointerconexion.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @ordenaccesointerconexion.asiento.tipo_asiento = "AS"
    @ordenaccesointerconexion.asiento.tipo_inscripcion = "Asiento Nuevo"
    @ordenaccesointerconexion.operadores_orden_acceso_interconexions.new
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @ordenaccesointerconexion = OrdenAccesoInterconexion.find(params[:id])
    @asiento = @ordenaccesointerconexion.asiento
    @ordenaccesointerconexion.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @ordenaccesointerconexion = OrdenAccesoInterconexion.new(orden_acceso_interconexion_params)

    if !is_asiento_nil? 
      if @ordenaccesointerconexion.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Orden Acceso Interconexión creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Orden Acceso Interconexión no creado, hay errores que corregir' 
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
    OrdenAccesoInterconexion.find(params[:id]).destroy
    flash.now[:success] = "OrdenAccesoInterconexion borrado"
    redirect_to orden_acceso_interconexions_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orden_acceso_interconexion
      @ordenaccesointerconexion = OrdenAccesoInterconexion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def orden_acceso_interconexion_params
        unless params[:orden_acceso_interconexion].empty? 
          params.require(:orden_acceso_interconexion).permit(:fecha_vigencia, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ], operadores_orden_acceso_interconexions_attributes: [:operador_regulados_id, :nombre_operador, :identificacion_operador, :nombre_representante_legal, :cedula_representante_legal])
        end
    end
    
    def is_asiento_nil?
      @ordenaccesointerconexion.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:orden_acceso_interconexion]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:acto_inscribible] = "OrdenAccesoInterconexion"
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
      neutro = params[:orden_acceso_interconexion]
      asiento = Asiento.new
      tramite = OrdenAccesoInterconexion.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key.include?("_attributes")
          tramite[key] = val if key != "id"
        end
      end

      #copiar detalle operadores 
      operadores_orden_acceso_interconexions = params[:orden_acceso_interconexion][:operadores_orden_acceso_interconexions_attributes]
      unless operadores_orden_acceso_interconexions.nil? 
        operadores_orden_acceso_interconexions.each do |sn|
          operador = tramite.operadores_orden_acceso_interconexions.new
          sn[1].each do |key, val|
            operador[key] = val if key != "id"
          end
        end
      end

      neutro = params[:orden_acceso_interconexion][:asiento_attributes]
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
      obj = OrdenAccesoInterconexion.find(params[:id])

      if  params[:orden_acceso_interconexion][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "OrdenAccesoInterconexion"
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

        # borrar objetos
        obj.asiento.destroy
        obj.destroy
      end
      #grabar objeto

      @ordenaccesointerconexion = tramite

      if @ordenaccesointerconexion.save
        flash.now[:success] = "Convenio Privado actualizado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Convenio Privado no modificado, hay errores que corregir' 
        render :edit
      end
    end

end
