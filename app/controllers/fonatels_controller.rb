class FonatelsController < ApplicationController
  
  PER_PAGE = 10

  def index
    @fonatels = Fonatel.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @fonatel = Fonatel.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @fonatel = Fonatel.new
    @fonatel.build_asiento

    @anatext_asiento = check_for_anatext @fonatel.asiento
    @fonatel.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @fonatel.asiento
    @fonatel.asiento.tipo_asiento = "AS"
    @fonatel.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @fonatel = Fonatel.find(params[:id])
    @asiento = @fonatel.asiento
    @fonatel.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @fonatel = Fonatel.new(fonatel_params)

    if !is_asiento_nil? 
      if @fonatel.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Informe Fonatel creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Informe Fonatel no creado, hay errores que corregir' 
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
    Fonatel.find(params[:id]).destroy
    flash.now[:success] = "Informe Fonatel borrado"
    redirect_to fonatels_url
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fonatel
      @fonatel = Fonatel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fonatel_params
        unless params[:fonatel].empty? 
          params.require(:fonatel).permit(:titulo_informe, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @fonatel.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:fonatel]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:acto_inscribible] = "Informe Fonatel"
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
      neutro = params[:fonatel]
      asiento = Asiento.new
      fonatel = Fonatel.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          fonatel[key] = val if key != "id"
        end
      end if neutro

      neutro = params[:fonatel][:asiento_attributes]
      #copiar objeto hijo existente
      neutro.each do |key, val|
        asiento[key] = val if key != "id"
      end

      #crear stub del hijo en el padre
      fonatel.build_asiento

      #copiar valores al hijo
      asiento.attributes.each do |key,val|
        fonatel.asiento[key] = asiento[key] if key != "id"
      end

      return fonatel
    end

    def clonar_objetos

      fonatel = clonar
      obj = Fonatel.find(params[:id])

      if  params[:fonatel][:asiento_attributes][:tipo_asiento]== "MD"
        fonatel.asiento.num_asiento_original = obj.asiento.num_asiento
        fonatel.asiento.num_asiento = obtener_numero_asiento("MD")
        fonatel.asiento.tipo_asiento = "MD"
        fonatel.asiento.tipo_inscripcion = "Modificación de Asiento"
        fonatel.asiento.acto_type = "Fonatel"
      else
        fonatel.asiento.num_asiento_original = obj.asiento.num_asiento_original
        fonatel.asiento.num_asiento = obj.asiento.num_asiento
        fonatel.asiento.tipo_asiento = obj.asiento.tipo_asiento
        fonatel.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        fonatel.asiento.acto_type = obj.asiento.acto_type
        fonatel.asiento.acto_inscribible = obj.asiento.acto_inscribible
        fonatel.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        # borrar objetos
        obj.asiento.destroy
        obj.destroy
      end
      #grabar objeto

      @fonatel = fonatel
      if @fonatel.save
        flash.now[:success] = "Informe Fonatel actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Informe Fonatel no modificado, hay errores que corregir' 
        render :edit
      end
    end

end
