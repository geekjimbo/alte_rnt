class RecursoNumericosController < ApplicationController
  #before_save :logged_in?, only: [:index, :edit, :update, :destroy]
  #before_action :set_asientos_fields
  
  PER_PAGE = 10

  def get_json
    operador_id = RecursoNumerico.find(params[:recurso_numerico][:asiento_attributesoperador][:operadorregulado_id])
    operador = OperadorRegulado.find(operador_id)
    render :text => operador.to_json
  end

  def index
    @recurso_numericos = RecursoNumerico.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @recurso_numerico = RecursoNumerico.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @recurso_numerico = RecursoNumerico.new
    @recurso_numerico.detalle_recurso_numericos.new
    @recurso_numerico.build_asiento

    @anatext_asiento = check_for_anatext @recurso_numerico.asiento
    @recurso_numerico.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @recurso_numerico.asiento
    @recurso_numerico.asiento.tipo_asiento = "AS"
    @recurso_numerico.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @recurso_numerico = RecursoNumerico.find(params[:id])
    @asiento = @recurso_numerico.asiento
    @recurso_numerico.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @recurso_numerico = RecursoNumerico.new(recurso_numerico_params)

    if !is_asiento_nil? 
      if @recurso_numerico.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Recurso Numérico creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Recurso Numérico no creado, hay errores que corregir' 
        render :new
      end
    else
        rende :new
    end
  end

  def update
    set_asientos_fields
  end

  def delete
  end

  def destroy
    RecursoNumerico.find(params[:id]).destroy
    flash.now[:success] = "Recurso Numérico borrado"
    redirect_to recurso_numericos_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recurso_numerico
      @recurso_numerico = RecursoNumerico.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurso_numerico_params
        unless params[:recurso_numerico].empty? 
          params.require(:recurso_numerico).permit(asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ], detalle_recurso_numericos_attributes: [:rango_numeracion, :numero_asignado, :tipo_recurso_numerico, :nota])
        end
    end
    
    def is_asiento_nil?
      @recurso_numerico.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:recurso_numerico]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:acto_inscribible] = "Recurso Numerico"
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
      neutro = params[:recurso_numerico]
      asiento = Asiento.new
      recurso_numerico = RecursoNumerico.new

      # copiar objeto padre existente
      #neutro.each do |key, val|
      #  unless key == "asiento_attributes" 
      #    recurso_numerico[key] = val if key != "id"
      #  end
      #end

      #crear stub del hijo en el padre
      detalle_recurso_numericos = params[:recurso_numerico][:detalle_recurso_numericos_attributes]
      unless detalle_recurso_numericos.nil? 
        detalle_recurso_numericos.each do |drn|
          detalle = recurso_numerico.detalle_recurso_numericos.new
          drn[1].each do |key, val|
            detalle[key] = val if key != "id"
          end
        end
      end

      neutro = params[:recurso_numerico][:asiento_attributes]
      recurso_numerico.build_asiento
      #copiar objeto hijo existente
      neutro.each do |key, val|
        asiento[key] = val if key != "id"
      end

      #copiar valores al hijo
      asiento.attributes.each do |key,val|
        recurso_numerico.asiento[key] = asiento[key] if key != "id"
      end
      return recurso_numerico
    end

    def clonar_objetos

      recurso_numerico = clonar
      # tercambiar llaves
      obj = RecursoNumerico.find(params[:id])

      if  params[:recurso_numerico][:asiento_attributes][:tipo_asiento]== "MD"
        recurso_numerico.asiento.num_asiento_original = obj.asiento.num_asiento
        recurso_numerico.asiento.num_asiento = obtener_numero_asiento("MD")
        recurso_numerico.asiento.tipo_asiento = "MD"
        recurso_numerico.asiento.tipo_inscripcion = "Modificación de Asiento"
        recurso_numerico.asiento.acto_type = "RecursoNumerico"
        recurso_numerico.asiento.acto_inscribible = obj.asiento.acto_inscribible
        recurso_numerico.asiento.fecha_solicitud = obj.asiento.fecha_solicitud
      else
        recurso_numerico.asiento.num_asiento_original = obj.asiento.num_asiento_original
        recurso_numerico.asiento.num_asiento = obj.asiento.num_asiento
        recurso_numerico.asiento.tipo_asiento = obj.asiento.tipo_asiento
        recurso_numerico.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        recurso_numerico.asiento.acto_type = obj.asiento.acto_type
        recurso_numerico.asiento.acto_inscribible = obj.asiento.acto_inscribible
        recurso_numerico.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        #borrar objetos
        obj.asiento.destroy
        obj.destroy
      end
      #grabar objeto
      @recurso_numerico = recurso_numerico

      if @recurso_numerico.save
        flash.now[:success] = "Recurso Numérico actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Recurso Numérico no modificado, hay errores que corregir' 
        render :edit
      end
    end
end
