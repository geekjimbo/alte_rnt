class ConvenioPrivadosController < ApplicationController
  #before_save :logged_in?, only: [:index, :edit, :update, :destroy]
  #before_action :set_asientos_fields
  
  PER_PAGE = 10

  def index
    @convenio_privados = ConvenioPrivado.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @convenio_privado = ConvenioPrivado.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @convenio_privado = ConvenioPrivado.new
    @convenio_privado.build_asiento

    @anatext_asiento = check_for_anatext @convenio_privado.asiento
    @convenio_privado.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @convenio_privado.asiento
    @convenio_privado.asiento.tipo_asiento = "AS"
    @convenio_privado.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @convenio_privado = ConvenioPrivado.find(params[:id])
    @asiento = @convenio_privado.asiento
    @convenio_privado.asiento.tipo_asiento = "ED"
    #@convenio_privado.asiento.tipo_inscripcion = "Modificación de Asiento"
  end

  def create
    set_asientos_fields
    @convenio_privado = ConvenioPrivado.new(convenio_privado_params)

    if !is_asiento_nil? 
      if @convenio_privado.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Convenio Privado creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
        #redirect_to edit_convenio_privado_path(@convenio_privado)
      else
        flash.now[:danger] = 'Convenio Privado no creado, hay errores que corregir' 
        @convenio_privado.build_asiento
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
    ConvenioPrivado.find(params[:id]).destroy
    flash.now[:success] = "ConvenioPrivado borrado"
    redirect_to convenio_privados_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_convenio_privado
      @convenio_privado = ConvenioPrivado.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def convenio_privado_params
        unless params[:convenio_privado].empty? 
          params.require(:convenio_privado).permit(:titulo_convenio, :fecha_suscripcion, :num_anexos, :fecha_vencimiento, :adendas,  :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @convenio_privado.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:convenio_privado]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:acto_inscribible] = "ConvenioPrivado"
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
      neutro = params[:convenio_privado]
      asiento = Asiento.new
      tramite = ConvenioPrivado.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          tramite[key] = val if key != "id"
        end
      end

      neutro = params[:convenio_privado][:asiento_attributes]
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

      #intercambiar llaves
      obj = ConvenioPrivado.find(params[:id])

      if  params[:convenio_privado][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "ConvenioPrivado"
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

      @convenio_privado = tramite
      #grabar objeto
      if @convenio_privado.save
        flash.now[:success] = "Convenio Privado actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Convenio Privado no modificado, hay errores que corregir' 
        render :edit
      end
    end

end
