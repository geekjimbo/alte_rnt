class LabsController < ApplicationController
  
  PER_PAGE = 10

  def index
    @labs = Lab.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @lab = Lab.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @lab = Lab.new
    @lab.build_asiento

    @anatext_asiento = check_for_anatext @lab.asiento
    @lab.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @lab.asiento
    @lab.asiento.tipo_asiento = "AS"
    @lab.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @lab = Lab.find(params[:id])
    @asiento = @lab.asiento
    @lab.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @lab = Lab.new(lab_params)

    if !is_asiento_nil? 
      if @lab.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Laboratorio creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
        #redirect_to edit_convenio_privado_path(@lab)
      else
        flash.now[:danger] = 'Laboratorio no creado, hay errores que corregir' 
        @lab.build_asiento
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
    Lab.find(params[:id]).destroy
    flash.now[:success] = "Lab borrado"
    redirect_to convenio_privados_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lab
      @lab = Lab.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lab_params
        unless params[:lab].empty? 
          params.require(:lab).permit(:nombre_acreditado, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @lab.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:lab]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.new
        end
        
        rn[:asiento_attributes][:vigencia2]=0
        rn[:asiento_attributes][:nombre_operador]
        rn[:asiento_attributes][:identificacion_operador]
        rn[:asiento_attributes][:acto_inscribible] = "Lab"
        rn[:asiento_attributes][:usuario] = current_user.id.to_s + "-" + current_user.email

        if action_name == 'update'
          clonar_objetos
        end
      end

    end

    def clonar
      neutro = params[:lab]
      asiento = Asiento.new
      tramite = Lab.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          tramite[key] = val if key != "id"
        end
      end

      neutro = params[:lab][:asiento_attributes]
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
      obj = Lab.find(params[:id])

      if  params[:lab][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "Lab"
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

      #grabar objeto
      @lab = tramite

      if @lab.save
        flash.now[:success] = "Laboratorio actualizado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Laboratorio no modificado, hay errores que corregir' 
        render :edit
      end

    end

end
