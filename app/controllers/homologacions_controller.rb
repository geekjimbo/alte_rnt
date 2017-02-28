class HomologacionsController < ApplicationController
  
  PER_PAGE = 10

  def index
    @homologacions = Homologacion.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @homologacion = Homologacion.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @homologacion = Homologacion.new
    @homologacion.build_asiento

    @anatext_asiento = check_for_anatext @homologacion.asiento
    @homologacion.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @homologacion.asiento
    @homologacion.asiento.tipo_asiento = "AS"
    @homologacion.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @homologacion = Homologacion.find(params[:id])
    @asiento = @homologacion.asiento
    @homologacion.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @homologacion = Homologacion.new(homologacion_params)

    if !is_asiento_nil? 
      if @homologacion.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Homologacion creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
        #redirect_to edit_convenio_privado_path(@homologacion)
      else
        flash.now[:danger] = 'Homologacion no creado, hay errores que corregir' 
        @homologacion.build_asiento
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
    Homologacion.find(params[:id]).destroy
    flash.now[:success] = "Homologacion borrado"
    redirect_to convenio_privados_url
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_homologacion
      @homologacion = Homologacion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def homologacion_params
        unless params[:homologacion].empty? 
          params.require(:homologacion).permit(:numero_oficio_remision, :fecha_actualizacion, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @homologacion.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:homologacion]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end

        rn[:asiento_attributes][:vigencia2] = 0
        rn[:asiento_attributes][:acto_inscribible] = "Homologacion"
        rn[:asiento_attributes][:usuario] = current_user.id.to_s + "-" + current_user.email
        rn[:asiento_attributes][:nombre_operador] = " "
        rn[:asiento_attributes][:identificacion_operador] = " "

        if action_name == 'update'
          clonar_objetos
        end
      end

    end

    def clonar
      neutro = params[:homologacion]
      asiento = Asiento.new
      tramite = Homologacion.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          tramite[key] = val if key != "id"
        end
      end

      neutro = params[:homologacion][:asiento_attributes]
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
      # generar nuevo id
      obj = Homologacion.find(params[:id])

      if  params[:homologacion][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "Homologacion"
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

        # borrar objetos
        obj.asiento.destroy
        obj.destroy
      end

      @homologacion = tramite
      #grabar objeto
      if @homologacion.save
        flash.now[:success] = "Homologacion actualizado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Homologacion no modificado, hay errores que corregir' 
        render :edit
      end
    end


end
