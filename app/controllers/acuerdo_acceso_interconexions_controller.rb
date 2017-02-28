class AcuerdoAccesoInterconexionsController < ApplicationController

  PER_PAGE = 10

  def index
    @acuerdo_acceso_interconexions = AcuerdoAccesoInterconexion.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.new
    @asiento = @acuerdo_acceso_interconexion.build_asiento
    @anatext_asiento = check_for_anatext @acuerdo_acceso_interconexion.asiento
    @acuerdo_acceso_interconexion.asiento = @anatext_asiento if !@anatext_asiento.nil?


    # build childs
    @acuerdo_acceso_interconexion.servicios_interconexion.new
    @acuerdo_acceso_interconexion.asiento.tipo_asiento = "AS"
    @acuerdo_acceso_interconexion.asiento.tipo_inscripcion = "Asiento Nuevo"
    @acuerdo_acceso_interconexion.operadores_acuerdo_acceso_interconexions.new
    @acuerdo_acceso_interconexion.operadores_acuerdo_acceso_interconexions.last.servicios_operadores_acuerdo_acceso_interconexions.new
    
  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
    @acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.find(params[:id])
    @asiento = @acuerdo_acceso_interconexion.asiento
    @acuerdo_acceso_interconexion.asiento.tipo_asiento = "ED"
    #@acuerdo_acceso_interconexion.asiento.tipo_inscripcion = "Modificación de Asiento"

    @servicios_interconexion = @acuerdo_acceso_interconexion.servicios_interconexion.first
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@acuerdo_acceso_interconexion = acuerdo_acceso_interconexion.new(acuerdo_acceso_interconexion_params)

    if !is_asiento_nil? 
      if @acuerdo_acceso_interconexion.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Acuerdo Acceso Interconexión creada exitosamente"
        redirect_to asientos_path
        #redirect_to acuerdo_acceso_interconexions_url
      else
        flash.now[:danger] = 'Acuerdo Acceso Interconexión no creada, hay errores que corregir' 
        render :new
      end
    else
        redirect_to asientos_path
    end
  end

  def update
    set_asientos_fields
    #create_ancestors_from_hash
    #@acuerdo_acceso_interconexion = acuerdo_acceso_interconexion.find(params[:id])
    #parametros = params[:acuerdo_acceso_interconexion][:asiento_attributes]

    #if !(@acuerdo_acceso_interconexion.asiento.tipo_asiento == "AS" and parametros[:tipo_asiento] == "MD" )
      #if @acuerdo_acceso_interconexion.update_attributes(acuerdo_acceso_interconexion_params)
    #else
    #  redirect_to asientos_path
    #end
  end

  def delete
  end

  def destroy
    acuerdo_acceso_interconexion.find(params[:id]).destroy
    flash.now[:success] = "Acuerdo Acceso Interconexión borrada"
    redirect_to asientos_path
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_acuerdo_acceso_interconexion
      @acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def acuerdo_acceso_interconexion_params
        unless params[:acuerdo_acceso_interconexion].empty? 
          params.require(:acuerdo_acceso_interconexion).permit(:titulo_acuerdo, :fecha_validez_acuerdo, :anexos, :adendas, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ], servicios_interconexion_attributes: [:servicio, :precio_interconexion, :sci_servicios_id, :id], operadores_acuerdo_acceso_interconexions_attributes: [:operador_regulados_id, :nombre_operador, :identificacion_operador, :nombre_representante_legal, :cedula_representante_legal, servicios_operadores_acuerdo_acceso_interconexions_attributes: [:precio_interconexion, :sci_servicios_id]])
        end
    end

    def is_asiento_nil?
      #check_stack_for_nil
      #@acuerdo_acceso_interconexionasiento.nil?
      @acuerdo_acceso_interconexion.nil?
    end

    def set_asientos_fields
      rn = params[:acuerdo_acceso_interconexion][:asiento_attributes]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          #rn[:fecha_solicitud] = Time.now if rn[:fecha_solicitud].nil? or rn[:fecha_solicitud].blank? or rn[:fecha_solicitud] == ""
        end

        rn[:acto_inscribible] = "acuerdo_acceso_interconexion"
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
      # clonar el acuerdo_acceso_interconexion y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto acuerdo_acceso_interconexion
      neutro = params[:acuerdo_acceso_interconexion]
      acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.new
      neutro.each do |key, val|
        unless key.include? "_attributes" 
          #unless acuerdo_acceso_interconexion[key].nil? 
            acuerdo_acceso_interconexion[key] = val if key != "id"
          #end
        end
      end

      #copiar detalle operadores 
      the_hash = params[:acuerdo_acceso_interconexion][:operadores_acuerdo_acceso_interconexions_attributes]
      operadores_acuerdo_acceso_interconexions = the_hash 
      unless operadores_acuerdo_acceso_interconexions.nil? 
        operadores_acuerdo_acceso_interconexions.each do |sn|
          operador = acuerdo_acceso_interconexion.operadores_acuerdo_acceso_interconexions.new
          sn[1].each do |key, val|
            operador[key] = val if key != "id" and !key.include?("_attributes")
          end
        end
      end

      # copiar objeto servicios interconexion
      # Aqui insertar logica para multiples servicios

      servicios_interconexion = neutro[:servicios_interconexion_attributes]
      unless servicios_interconexion.nil? 
        servicios_interconexion.each do |sn|
          sci_servicio = acuerdo_acceso_interconexion.servicios_interconexion.new
          sn[1].each do |key, val|
            sci_servicio[key] = val if key != "id"
          end
        end
      end
        

      asiento = acuerdo_acceso_interconexion.build_asiento
      neutro = params[:acuerdo_acceso_interconexion][:asiento_attributes]
      #copiar objeto asiento
      neutro.each do |key, val|
        #unless asiento[key].nil?
          asiento[key] = val if key != "id"
        #end
      end
      return acuerdo_acceso_interconexion
    end

    def borrar_objetos(child)
      unless child.nil? 
        child.each do |c|
          c.destroy
        end
      end
    end

    def clonar_objetos
      acuerdo_acceso_interconexion = clonar

      #intercambiar llaves
      obj = AcuerdoAccesoInterconexion.find(params[:id])
      #if obj.asiento.tipo_asiento == "AS" and params[:acuerdo_acceso_interconexion][:asiento_attributes][:tipo_asiento] == "MD"
      if  params[:acuerdo_acceso_interconexion][:asiento_attributes][:tipo_asiento]== "MD"
          acuerdo_acceso_interconexion.asiento.num_asiento_original = obj.asiento.num_asiento
          acuerdo_acceso_interconexion.asiento.num_asiento = obtener_numero_asiento("MD")
          acuerdo_acceso_interconexion.asiento.tipo_asiento = "MD"
          acuerdo_acceso_interconexion.asiento.tipo_inscripcion = "Modificación de Asiento"
          acuerdo_acceso_interconexion.asiento.acto_type = "AcuerdoAccesoInterconexion"
          acuerdo_acceso_interconexion.asiento.acto_inscribible = obj.asiento.acto_inscribible
      else
          acuerdo_acceso_interconexion.asiento.num_asiento_original = obj.asiento.num_asiento_original
          acuerdo_acceso_interconexion.asiento.num_asiento = obj.asiento.num_asiento
          acuerdo_acceso_interconexion.asiento.tipo_asiento = obj.asiento.tipo_asiento
          acuerdo_acceso_interconexion.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
          acuerdo_acceso_interconexion.asiento.acto_type = obj.asiento.acto_type
          acuerdo_acceso_interconexion.asiento.acto_inscribible = obj.asiento.acto_inscribible
          acuerdo_acceso_interconexion.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

          #borrar objetos
          borrar_objetos(obj.servicios_interconexion)
          obj.destroy
      end

      #grabar objeto
      @acuerdo_acceso_interconexion = acuerdo_acceso_interconexion
      if @acuerdo_acceso_interconexion.save
        #@acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.find(params[:id])
        @consecutivo.save if !@consecutivo.nil?
        flash.now[:success] = "Acuerdo Acceso Interconexión actualizado exitosamente"
        redirect_to asientos_path
      else
        #@acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.find(params[:id])
        flash.now[:danger] = 'Acuerdo Acceso Interconexión no modificado, hay errores que corregir' 
        render :edit
      end
    end

    def check_stack_for_nil
      #build stack up
      @acuerdo_acceso_interconexion if @acuerdo_acceso_interconexion.nil? 
      @acuerdo_acceso_interconexion.build_asiento if @acuerdo_acceso_interconexion.asiento.nil?
      @acuerdo_acceso_interconexion.servicios_interconexion.new if !@acuerdo_acceso_interconexion.servicios_interconexion.any?
    end

    def create_ancestors_from_hash
      @acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.new(acuerdo_acceso_interconexion_params) if action_name == "create"
      @acuerdo_acceso_interconexion = AcuerdoAccesoInterconexion.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:acuerdo_acceso_interconexion][:asiento_attributes]

      @acuerdo_acceso_interconexion.asiento.num_asiento = hash[:num_asiento] if action_name == "create"
      @acuerdo_acceso_interconexion.asiento.num_asiento_original = hash[:num_asiento_original]
      @acuerdo_acceso_interconexion.asiento.acto_inscribible = hash[:acto_inscribible]
      @acuerdo_acceso_interconexion.asiento.tipo_asiento = hash[:tipo_asiento]
      @acuerdo_acceso_interconexion.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @acuerdo_acceso_interconexion.asiento.numero_resolucion = hash[:numero_resolucion]
      @acuerdo_acceso_interconexion.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @acuerdo_acceso_interconexion.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @acuerdo_acceso_interconexion.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @acuerdo_acceso_interconexion.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @acuerdo_acceso_interconexion.asiento.nombre_operador = hash[:nombre_operador]
      @acuerdo_acceso_interconexion.asiento.identificacion_operador = hash[:identificacion_operador]
      @acuerdo_acceso_interconexion.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @acuerdo_acceso_interconexion.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @acuerdo_acceso_interconexion.asiento.usuario = hash[:usuario]
      @acuerdo_acceso_interconexion.asiento.enlace_documento = hash[:enlace_documento]
      @acuerdo_acceso_interconexion.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @acuerdo_acceso_interconexion.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @acuerdo_acceso_interconexion.asiento.vigencia2 = hash[:vigencia2]
      @acuerdo_acceso_interconexion.asiento.acto_id = hash[:acto_id]
      @acuerdo_acceso_interconexion.asiento.acto_type = "AcuerdoAccesoInterconexion"

    end

end
