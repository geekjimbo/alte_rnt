class SancionsController < ApplicationController

  PER_PAGE = 10

  def index
    @sancions = Sancion.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @sancion = Sancion.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @sancion = Sancion.new
    @sancion.build_asiento

    @anatext_asiento = check_for_anatext @sancion.asiento
    @sancion.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @sancion.asiento
    @sancion.asiento.tipo_asiento = "AS"
    @sancion.asiento.tipo_inscripcion = "Asiento Nuevo"
    @tipo_sancion = TipoSancion.all
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @sancion = Sancion.find(params[:id])
    @asiento = @sancion.asiento
    @sancion.asiento.tipo_asiento = "ED"
    @tipo_sancion = TipoSancion.all
  end

  def create
    set_asientos_fields
    @sancion = Sancion.new(sancion_params)

    if !is_asiento_nil? 
      if @sancion.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Sanción  creada exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Sanción no creada, hay errores que corregir' 
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
    Sancion.find(params[:id]).destroy
    flash.now[:success] = "Sanción  borrada"
    redirect_to sancion_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sancion_equipo
      @sancion = Sancion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sancion_params
        unless params[:sancion].empty? 
          params.require(:sancion).permit(:fecha_vigencia, :tipo_sancion ,:nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @sancion.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:sancion]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:acto_inscribible] = "Sancion"
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
      neutro = params[:sancion]
      asiento = Asiento.new
      tramite = Sancion.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          tramite[key] = val if key != "id"
        end
      end

      neutro = params[:sancion][:asiento_attributes]
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
      obj = Sancion.find(params[:id])

      if  params[:sancion][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "Sancion"
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

        #borrr objetos
        obj.asiento.destroy
        obj.destroy
      end

      #grabar objeto
      @sancion = tramite

      if @sancion.save
        flash.now[:success] = "Sanción  actualizada exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Sanción  no modificada, hay errores que corregir' 
        render :edit
      end
    end

end
