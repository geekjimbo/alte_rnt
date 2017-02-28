class ContratoAdhesionsController < ApplicationController

  PER_PAGE = 10

  def index
    @contrato_adhesions = ContratoAdhesion.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @contrato_adhesion = ContratoAdhesion.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @contrato_adhesion = ContratoAdhesion.new
    @asiento = @contrato_adhesion.build_asiento

    @anatext_asiento = check_for_anatext @contrato_adhesion.asiento
    @contrato_adhesion.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @contrato_adhesion.asiento.tipo_asiento = "AS"
    @contrato_adhesion.asiento.tipo_inscripcion = "Asiento Nuevo"
    # build childs
    @contrato_adhesion.servicio_contrato_adhesions.new
  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
    @contrato_adhesion = ContratoAdhesion.find(params[:id])
    @asiento = @contrato_adhesion.asiento
    @contrato_adhesion.asiento.tipo_asiento = "ED"
    #@contrato_adhesion.asiento.tipo_inscripcion = "Modificación de Asiento"

    #@servicios_interconexion = @contrato_adhesion.servicios_interconexion.first
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@contrato_adhesion = contrato_adhesion.new(contrato_adhesion_params)

    if !is_asiento_nil? 
      if @contrato_adhesion.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Contrato de Adhesión creada exitosamente"
        redirect_to asientos_path
        #redirect_to contrato_adhesions_url
      else
        flash.now[:danger] = 'Contrato de Adhesión no creada, hay errores que corregir' 
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
    contrato_adhesion.find(params[:id]).destroy
    flash.now[:success] = "Contrato de Adhesión borrada"
    redirect_to asientos_path
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contrato_adhesion
      @contrato_adhesion = ContratoAdhesion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contrato_adhesion_params
        unless params[:contrato_adhesion].empty? 
          params.require(:contrato_adhesion).permit(:titulo_contrato, :fecha_vigencia, :estado_contrato, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ], servicio_contrato_adhesions_attributes: [:servicio, :sci_servicios_id, :id])
        end
    end
    
    def is_asiento_nil?
      #check_stack_for_nil
      #@contrato_adhesionasiento.nil?
      @contrato_adhesion.nil?
    end

    def set_asientos_fields
      rn = params[:contrato_adhesion][:asiento_attributes]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          rn[:fecha_solicitud] = Time.now
        end

        rn[:acto_inscribible] = "contrato_adhesion"
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
      # clonar el contrato_adhesion y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto contrato_adhesion
      neutro = params[:contrato_adhesion]
      contrato_adhesion = ContratoAdhesion.new
      neutro.each do |key, val|
        unless key.include? "_attributes" 
          contrato_adhesion[key] = val if key != "id"
        end
      end

      # copiar objeto servicios contrato adhesions
      servicio_contrato_adhesions = neutro[:servicio_contrato_adhesions_attributes]
      unless servicio_contrato_adhesions.nil? 
        servicio_contrato_adhesions.each do |sn|
          sci_servicio = contrato_adhesion.servicio_contrato_adhesions.new
          sn[1].each do |key, val|
            sci_servicio[key] = val if key != "id"
          end
        end
      end


      asiento = contrato_adhesion.build_asiento
      neutro = params[:contrato_adhesion][:asiento_attributes]
      #copiar objeto asiento
      neutro.each do |key, val|
        asiento[key] = val if key != "id"
      end
      
      return contrato_adhesion
    end

    def borrar_objetos(child)
      unless child.nil? 
        child.each do |c|
          c.destroy
        end
      end
    end

    def clonar_objetos

      contrato_adhesion = clonar
      obj = ContratoAdhesion.find(params[:id])
      if  params[:contrato_adhesion][:asiento_attributes][:tipo_asiento]== "MD"
        contrato_adhesion.asiento.num_asiento_original = obj.asiento.num_asiento
        contrato_adhesion.asiento.num_asiento = obtener_numero_asiento("MD") 
        contrato_adhesion.asiento.tipo_asiento = "MD"
        contrato_adhesion.asiento.tipo_inscripcion = "Modificación de Asiento"
        contrato_adhesion.asiento.acto_type = "ContratoAdhesion"
      else
        contrato_adhesion.asiento.num_asiento_original = obj.asiento.num_asiento_original
        contrato_adhesion.asiento.num_asiento = obj.asiento.num_asiento 
        contrato_adhesion.asiento.tipo_asiento = obj.asiento.tipo_asiento
        contrato_adhesion.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        contrato_adhesion.asiento.acto_type = obj.asiento.acto_type
        contrato_adhesion.asiento.acto_inscribible = obj.asiento.acto_inscribible
        contrato_adhesion.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        #borrar objetos
        borrar_objetos(obj.servicio_contrato_adhesions)
        obj.asiento.destroy
        obj.destroy
      end
      #grabar objeto

      @contrato_adhesion = contrato_adhesion
      if @contrato_adhesion.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Contrato de Adhesión actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Contrato de Adhesión no modificado, hay errores que corregir' 
        render :edit
      end
  end

    def check_stack_for_nil
      #build stack up
      @contrato_adhesion if @contrato_adhesion.nil? 
      @contrato_adhesion.build_asiento if @contrato_adhesion.asiento.nil?
      @contrato_adhesion.servicio_contrato_adhesions.new if !@contrato_adhesion.servicio_contrato_adhesions.any?
    end

    def create_ancestors_from_hash
      @contrato_adhesion = ContratoAdhesion.new(contrato_adhesion_params) if action_name == "create"
      @contrato_adhesion = ContratoAdhesion.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:contrato_adhesion][:asiento_attributes]

      @contrato_adhesion.asiento.num_asiento = hash[:num_asiento] if action_name == "create"
      @contrato_adhesion.asiento.num_asiento_original = hash[:num_asiento_original]
      @contrato_adhesion.asiento.acto_inscribible = hash[:acto_inscribible]
      @contrato_adhesion.asiento.tipo_asiento = hash[:tipo_asiento]
      @contrato_adhesion.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @contrato_adhesion.asiento.numero_resolucion = hash[:numero_resolucion]
      @contrato_adhesion.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @contrato_adhesion.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @contrato_adhesion.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @contrato_adhesion.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @contrato_adhesion.asiento.nombre_operador = hash[:nombre_operador]
      @contrato_adhesion.asiento.identificacion_operador = hash[:identificacion_operador]
      @contrato_adhesion.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @contrato_adhesion.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @contrato_adhesion.asiento.usuario = hash[:usuario]
      @contrato_adhesion.asiento.enlace_documento = hash[:enlace_documento]
      @contrato_adhesion.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @contrato_adhesion.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @contrato_adhesion.asiento.vigencia2 = hash[:vigencia2]
      @contrato_adhesion.asiento.acto_id = hash[:acto_id]
      @contrato_adhesion.asiento.acto_type = "ContratoAdhesion"

    end


end
