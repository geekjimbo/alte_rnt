class PreciosTarifasController < ApplicationController

  PER_PAGE = 10

  def index
    @preciostarifa = PreciosTarifa.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @preciostarifa = PreciosTarifa.find(params[:id])
  end

  def new
    @servicios = SciServicio.all.order('descripcion')
    @preciostarifa = PreciosTarifa.new
    @preciostarifa.build_asiento

    @anatext_asiento = check_for_anatext @preciostarifa.asiento
    @preciostarifa.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @preciostarifa.asiento
    @preciostarifa.asiento.tipo_asiento = "AS"
    @preciostarifa.asiento.tipo_inscripcion = "Asiento Nuevo"
    @preciostarifa.detalle_precios_tarifas.new
  end

  def edit
    @servicios = SciServicio.all.order('descripcion')
    @preciostarifa = PreciosTarifa.find(params[:id])
    @asiento = @preciostarifa.asiento
    @preciostarifa.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @preciostarifa = PreciosTarifa.new(precios_tarifas_params)

    if !is_asiento_nil? 
      if @preciostarifa.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Aprobación de Precios y Tarifas creada exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Aprobación de Precios y Tarifas no creada!, hay errores que corregir' 
        @preciostarifa.build_asiento
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
    PreciosTarifa.find(params[:id]).destroy
    flash.now[:success] = "Precios y Tarifas borradas"
    redirect_to precios_tarifas_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resolucion_ubicacion_equipo
      @preciostarifa = PreciosTarifa.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def precios_tarifas_params
        unless params[:precios_tarifa].empty? 
          params.require(:precios_tarifa).permit(:tipo_precio_tarifa, :fecha_publicacion_gaceta, :numero_publicacion_gaceta, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ], detalle_precios_tarifas_attributes: [:tipo_precio_tarifa, :servicio, :modalidad, :precio_tarifa, :fecha_vigencia, :estado, :sci_servicios_id])
        end
    end
    
    def is_asiento_nil?
      @preciostarifa.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:precios_tarifa]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:acto_inscribible] = "PreciosTarifa"
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
      neutro = params[:precios_tarifa]
      asiento = Asiento.new
      tramite = PreciosTarifa.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key.include?("_attributes")
          tramite[key] = val if key != "id"
        end
      end

      #copiar detalle precios y tarifas
      detalle_precios_tarifas = params[:precios_tarifa][:detalle_precios_tarifas_attributes]
      unless detalle_precios_tarifas.nil? 
        detalle_precios_tarifas.each do |sn|
          precio_tarifa = tramite.detalle_precios_tarifas.new
          sn[1].each do |key, val|
            precio_tarifa[key] = val if key != "id"
          end
        end
      end

      neutro = params[:precios_tarifa][:asiento_attributes]
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
      # intercambiar llaves
      obj = PreciosTarifa.find(params[:id])

      if  params[:precios_tarifa][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "PreciosTarifa"
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
      
      @preciostarifa = tramite

      if @preciostarifa.save
        flash.now[:success] = "Aprobación de Precios y Tarifas actualizada exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Aprobación de Precios y Tarifas no modificada, hay errores que corregir' 
        render :edit
      end
    end

end
