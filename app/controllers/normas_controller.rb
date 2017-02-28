class NormasController < ApplicationController
  
  PER_PAGE = 10

  def index
    @normas = Norma.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @norma = Norma.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @norma = Norma.new
    @norma.build_asiento

    @anatext_asiento = check_for_anatext @norma.asiento
    @norma.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @norma.asiento
    @norma.asiento.tipo_asiento = "AS"
    @norma.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @norma = Norma.find(params[:id])
    @asiento = @norma.asiento
    @norma.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @norma = Norma.new(norma_params)

    if !is_asiento_nil? 
      if @norma.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Norma y estandr de Calidad creada exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Norma y estandar de Calidad no creada, hay errores que corregir' 
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
    Norma.find(params[:id]).destroy
    flash.now[:success] = "Norma y estándar de calidad borrada"
    redirect_to asientos_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_norma
      @norma = Norma.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def norma_params
        unless params[:norma].empty? 
          params.require(:norma).permit(:fecha_vigencia, :reforma, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @norma.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:norma]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:acto_inscribible] = "Norma"
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
      neutro = params[:norma]
      asiento = Asiento.new
      norma = Norma.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          norma[key] = val if key != "id"
        end
      end

      neutro = params[:norma][:asiento_attributes]
      #copiar objeto hijo existente
      neutro.each do |key, val|
        asiento[key] = val if key != "id"
      end

      #crear stub del hijo en el padre
      norma.build_asiento

      #copiar valores al hijo
      asiento.attributes.each do |key,val|
        norma.asiento[key] = asiento[key] if key != "id"
      end
      return norma
    end

    def clonar_objetos

      norma = clonar
      obj = Norma.find(params[:id])

      if  params[:norma][:asiento_attributes][:tipo_asiento]== "MD"
        norma.asiento.num_asiento_original = obj.asiento.num_asiento
        norma.asiento.num_asiento = obtener_numero_asiento("MD")
        norma.asiento.tipo_asiento = "MD"
        norma.asiento.tipo_inscripcion = "Modificación de Asiento"
        norma.asiento.acto_type = "Norma"
        norma.asiento.acto_inscribible = obj.asiento.acto_inscribible
        norma.asiento.fecha_solicitud = obj.asiento.fecha_solicitud
      else
        norma.asiento.num_asiento_original = obj.asiento.num_asiento_original
        norma.asiento.num_asiento = obj.asiento.num_asiento
        norma.asiento.tipo_asiento = obj.asiento.tipo_asiento
        norma.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        norma.asiento.acto_type = obj.asiento.acto_type
        norma.asiento.acto_inscribible = obj.asiento.acto_inscribible
        norma.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        #borrar objetos
        obj.asiento.destroy
        obj.destroy
      end

      #grabar objeto

      @norma = norma
      if @norma.save
        flash.now[:success] = "Norma y estándar de Calidad actualizada exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Norma y estándar de Calidad no modificada, hay errores que corregir' 
        render :edit
      end
    end

end
