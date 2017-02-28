class ConvenioInternacionalsController < ApplicationController
  
  PER_PAGE = 10

  def index
    @convenio_internacionals = ConvenioInternacional.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @convenio_internacional = ConvenioInternacional.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @convenio_internacional = ConvenioInternacional.new
    @convenio_internacional.build_asiento

    @anatext_asiento = check_for_anatext @convenio_internacional.asiento
    @convenio_internacional.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @convenio_internacional.asiento
    @convenio_internacional.asiento.tipo_asiento = "AS"
    @convenio_internacional.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @convenio_internacional = ConvenioInternacional.find(params[:id])
    @asiento = @convenio_internacional.asiento
    @convenio_internacional.asiento.tipo_asiento = "ED"
    #@convenio_internacional.asiento.tipo_inscripcion = "Modificación de Asiento"
  end

  def create
    set_asientos_fields
    @convenio_internacional = ConvenioInternacional.new(convenio_internacional_params)

    if !is_asiento_nil? 
      if @convenio_internacional.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Convenio Internacional creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Convenio Internacional no creado, hay errores que corregir' 
        render :new
      end
    else
        redirect_to asientos_path
    end
  end

  def update
    set_asientos_fields
    #@convenio_internacional = ConvenioInternacional.find(params[:id])

  end

  def delete
  end

  def destroy
    ConvenioInternacional.find(params[:id]).destroy
    flash.now[:success] = "Convenio Internacional borrado"
    redirect_to convenio_internacionals_url
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_convenio_internaional
      @convenio_internaional = ConvenioInternaional.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def convenio_internaional_params
      params[:convenio_internaional]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def convenio_internacional_params
        unless params[:convenio_internacional].empty? 
          params.require(:convenio_internacional).permit(:titulo_convenio, :numero_ley_aprobacion, :fecha_vigencia, :enmiendas, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @convenio_internacional.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:convenio_internacional]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.now
        end

        rn[:asiento_attributes][:acto_inscribible] = "Convenio Internacional"
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
      neutro = params[:convenio_internacional]
      convenio_internacional = ConvenioInternacional.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          convenio_internacional[key] = val if key != "id"
        end
      end

      #copiar objeto hijo existente
      neutro = params[:convenio_internacional][:asiento_attributes]
      asiento = convenio_internacional.build_asiento
      neutro.each do |key, val|
        asiento[key] = val if key != "id"
      end

      #crear stub del hijo en el padre
      convenio_internacional.build_asiento

      #copiar valores al hijo
      asiento.attributes.each do |key,val|
        convenio_internacional.asiento[key] = asiento[key] if key != "id"
      end
      return convenio_internacional
    end

    def clonar_objetos

      convenio_internacional = clonar
      #intercambiar llaves
      obj = ConvenioInternacional.find(params[:id])

      if  params[:convenio_internacional][:asiento_attributes][:tipo_asiento]== "MD"
        convenio_internacional.asiento.num_asiento_original = obj.asiento.num_asiento
        convenio_internacional.asiento.num_asiento = obtener_numero_asiento("MD")
        convenio_internacional.asiento.tipo_asiento = "MD"
        convenio_internacional.asiento.tipo_inscripcion = "Modificación de Asiento"
        convenio_internacional.asiento.acto_type = "ConvenioInternacional"
      else
        convenio_internacional.asiento.num_asiento_original = obj.asiento.num_asiento_original
        convenio_internacional.asiento.num_asiento = obj.asiento.num_asiento
        convenio_internacional.asiento.tipo_asiento = obj.asiento.tipo_asiento
        convenio_internacional.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        convenio_internacional.asiento.acto_type = obj.asiento.acto_type
        convenio_internacional.asiento.acto_inscribible = obj.asiento.acto_inscribible
        convenio_internacional.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        #borrar objetos
        obj.asiento.destroy
        obj.destroy
      end
      @convenio_internacional = convenio_internacional

      #grabar objeto
      if @convenio_internacional.save
        @consecutivo.save if !@consecutivo.nil?
        flash.now[:success] = "Convenio Internacional actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Convenio Internacional no modificado, hay errores que corregir' 
        render :edit
      end
  end
end
