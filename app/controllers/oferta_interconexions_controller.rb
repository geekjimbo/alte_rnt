class OfertaInterconexionsController < ApplicationController

  PER_PAGE = 10

  def index
    @oferta_interconexions = OfertaInterconexion.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @oferta_interconexion = OfertaInterconexion.find(params[:id])
  end

  def new
    # prepare lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')
    
    # create root parent
    @oferta_interconexion = OfertaInterconexion.new
    @asiento = @oferta_interconexion.build_asiento

    @anatext_asiento = check_for_anatext @oferta_interconexion.asiento
    @oferta_interconexion.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @oferta_interconexion.asiento.tipo_asiento = "AS"
    @oferta_interconexion.asiento.tipo_inscripcion = "Asiento Nuevo"
    # build childs
    @oferta_interconexion.oferta_interconexion_servicios.new
  end

  def edit
    #lookups
    @operadores = OperadorRegulado.all.order('nombre')
    @servicios = SciServicio.all.order('descripcion')

    # parent
    @oferta_interconexion = OfertaInterconexion.find(params[:id])
    @asiento = @oferta_interconexion.asiento
    @oferta_interconexion.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    create_ancestors_from_hash
    #@oferta_interconexion = OfertaInterconexion.new(oferta_interconexion_params)

    if !is_asiento_nil? 
      if @oferta_interconexion.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Oferta Interconexión creada exitosamente"
        redirect_to asientos_path
        #redirect_to oferta_interconexions_url
      else
        flash.now[:danger] = 'Oferta Interconexión no creada, hay errores que corregir' 
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
    OfertaInterconexion.find(params[:id]).destroy
    flash.now[:success] = "Oferta Interconexión borrada"
    redirect_to asientos_path
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oferta_interconexion
      @oferta_interconexion = OfertaInterconexion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def oferta_interconexion_params
        unless params[:oferta_interconexion].empty? 
          params.require(:oferta_interconexion).permit(:numero_publicacion_gaceta, :fecha_publicacion_gaceta, :contenido_oferta, :fecha_vencimiento, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ], oferta_interconexion_servicios_attributes: [:id, :sci_servicios_id, :servicio, :precio])
        end
    end
    
    def is_asiento_nil?
      #check_stack_for_nil
      #@oferta_interconexionasiento.nil?
      @oferta_interconexion.nil?
    end

    def set_asientos_fields
      rn = params[:oferta_interconexion][:asiento_attributes]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          rn[:fecha_solicitud] = Time.now
        end

        rn[:acto_inscribible] = "oferta_interconexion"
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
      # clonar el oferta_interconexion y toda la jerarquía incluyendo los objetos anidados y los objetos ancestros
      # copiar objeto oferta_interconexion
      neutro = params[:oferta_interconexion]
      oferta_interconexion = OfertaInterconexion.new
      neutro.each do |key, val|
        unless key.include? "_attributes" 
          oferta_interconexion[key] = val if key != "id"
        end
      end if neutro

      # copiar objeto servicios interconexion
      # Aqui insertar logica para multiples servicios

      servicios = neutro[:oferta_interconexion_servicios_attributes]
      unless servicios.nil? 
        servicios.each do |sn|
          sci_servicio = oferta_interconexion.oferta_interconexion_servicios.new
          sn[1].each do |key, val|
            sci_servicio[key] = val if key != "id"
          end
        end
      end

      asiento = oferta_interconexion.build_asiento
      neutro = params[:oferta_interconexion][:asiento_attributes]
      #copiar objeto asiento
      neutro.each do |key, val|
        asiento[key] = val if key != "id"
      end
      return oferta_interconexion
    end

    def clonar_objetos
      
      oferta_interconexion = clonar
      #intercambiar llaves
      obj = OfertaInterconexion.find(params[:id])

      if  params[:oferta_interconexion][:asiento_attributes][:tipo_asiento]== "MD"
        oferta_interconexion.asiento.num_asiento_original = obj.asiento.num_asiento
        oferta_interconexion.asiento.num_asiento = obtener_numero_asiento("MD")
        oferta_interconexion.asiento.tipo_asiento = "MD"
        oferta_interconexion.asiento.tipo_inscripcion = "Modificación de Asiento"
        oferta_interconexion.asiento.acto_type = "OfertaInterconexion"
        oferta_interconexion.asiento.acto_inscribible = obj.asiento.acto_inscribible
        oferta_interconexion.asiento.fecha_solicitud = obj.asiento.fecha_solicitud
      else
        oferta_interconexion.asiento.num_asiento_original = obj.asiento.num_asiento_original
        oferta_interconexion.asiento.num_asiento = obj.asiento.num_asiento
        oferta_interconexion.asiento.tipo_asiento = obj.asiento.tipo_asiento
        oferta_interconexion.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        oferta_interconexion.asiento.acto_type = obj.asiento.acto_type
        oferta_interconexion.asiento.acto_inscribible = obj.asiento.acto_inscribible
        oferta_interconexion.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        #borrar objetos
        borrar_objetos(obj.oferta_interconexion_servicios)
        obj.asiento.destroy
        obj.destroy
      end

      #if @oferta_interconexion.update_attributes(oferta_interconexion_params)
      @oferta_interconexion = oferta_interconexion
      if @oferta_interconexion.save
        flash.now[:success] = "Oferta Interconexión actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Oferta Interconexión no modificado, hay errores que corregir' 
        render :edit
      end
    end

    def check_stack_for_nil
      #build stack up
      @oferta_interconexion if @oferta_interconexion.nil? 
      @oferta_interconexion.build_asiento if @oferta_interconexion.asiento.nil?
      @oferta_interconexion.oferta_interconexion_servicios.new if !@oferta_interconexion.oferta_interconexion_servicios.any?
    end

    def create_ancestors_from_hash
      @oferta_interconexion = OfertaInterconexion.new(oferta_interconexion_params) if action_name == "create"
      @oferta_interconexion = OfertaInterconexion.find(params[:id]) if action_name != "create"
      check_stack_for_nil

      hash = params[:oferta_interconexion][:asiento_attributes]
      @oferta_interconexion.asiento.acto_inscribible = hash[:acto_inscribible]
      @oferta_interconexion.asiento.tipo_asiento = hash[:tipo_asiento]
      @oferta_interconexion.asiento.tipo_inscripcion = hash[:tipo_inscripcion] if action_name =="create"
      @oferta_interconexion.asiento.numero_resolucion = hash[:numero_resolucion]
      @oferta_interconexion.asiento.nombre_resolucion = hash[:nombre_resolucion]
      @oferta_interconexion.asiento.titulo_resolucion = hash[:titulo_resolucion]
      @oferta_interconexion.asiento.fecha_resolucion = hash[:fecha_resolucion]
      @oferta_interconexion.asiento.fecha_solicitud = hash[:fecha_solicitud]
      @oferta_interconexion.asiento.nombre_operador = hash[:nombre_operador]
      @oferta_interconexion.asiento.identificacion_operador = hash[:identificacion_operador]
      @oferta_interconexion.asiento.nombre_representante_legal = hash[:nombre_representante_legal]
      @oferta_interconexion.asiento.cedula_representante_legal = hash[:cedula_representante_legal]
      @oferta_interconexion.asiento.usuario = hash[:usuario]
      @oferta_interconexion.asiento.enlace_documento = hash[:enlace_documento]
      @oferta_interconexion.asiento.num_expediente_sutel = hash[:num_expediente_sutel]
      @oferta_interconexion.asiento.operadorregulado_id = hash[:operadorregulado_id]
      @oferta_interconexion.asiento.vigencia2 = hash[:vigencia2]
      @oferta_interconexion.asiento.acto_id = hash[:acto_id]
      @oferta_interconexion.asiento.acto_type = "OfertaInterconexion"
end


end
