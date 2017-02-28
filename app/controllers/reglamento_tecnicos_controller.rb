class ReglamentoTecnicosController < ApplicationController
  
  PER_PAGE = 10

  def index
    @reglamento_tecnicos = ReglamentoTecnico.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @reglamento_tecnico = ReglamentoTecnico.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @reglamento_tecnico = ReglamentoTecnico.new
    @reglamento_tecnico.build_asiento

    @anatext_asiento = check_for_anatext @reglamento_tecnico.asiento
    @reglamento_tecnico.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @reglamento_tecnico.asiento
    @reglamento_tecnico.asiento.tipo_asiento = "AS"
    @reglamento_tecnico.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @reglamento_tecnico = ReglamentoTecnico.find(params[:id])
    @asiento = @reglamento_tecnico.asiento
    @reglamento_tecnico.asiento.tipo_asiento = "ED"
  end

  def create
    set_asientos_fields
    @reglamento_tecnico = ReglamentoTecnico.new(reglamento_tecnico_params)

    if !is_asiento_nil? 
      if @reglamento_tecnico.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Reglamento Técnico creado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
        #redirect_to edit_convenio_privado_path(@reglamento_tecnico)
      else
        flash.now[:danger] = 'Reglamento Técnico no creado, hay errores que corregir' 
        @reglamento_tecnico.build_asiento
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
    ReglamentoTecnico.find(params[:id]).destroy
    flash.now[:success] = "ReglamentoTecnico borrado"
    redirect_to convenio_privados_url
  end


  private
    def set_reglamento_tecnico
      @reglamento_tecnico = ReglamentoTecnico.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reglamento_tecnico_params
        unless params[:reglamento_tecnico].empty? 
          params.require(:reglamento_tecnico).permit(:titulo_reglamento, :fecha_vigencia, :reformas, :numero_aprobacion_aresep, :fecha_aprobacion, :nota, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @reglamento_tecnico.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:reglamento_tecnico]
      unless rn.nil?
        if action_name == "create"
          rn[:asiento_attributes][:num_asiento_original] = ""
          rn[:asiento_attributes][:num_asiento] = obtener_numero_asiento("AS")
          rn[:asiento_attributes][:tipo_inscripcion] = "Asiento Nuevo"
          rn[:asiento_attributes][:tipo_asiento] = "AS"
          rn[:asiento_attributes][:fecha_solicitud] = Time.now
        end

        rn[:asiento_attributes][:acto_inscribible] = "ReglamentoTecnico"
        rn[:asiento_attributes][:usuario] = current_user.id.to_s + "-" + current_user.email
        
        rn[:asiento_attributes][:nombre_operador] = " "
        rn[:asiento_attributes][:identificacion_operador] = " "
        if action_name == 'update'
          clonar_objetos
        end
      end

    end

    def clonar
      neutro = params[:reglamento_tecnico]
      asiento = Asiento.new
      tramite = ReglamentoTecnico.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          tramite[key] = val if key != "id"
        end
      end

      neutro = params[:reglamento_tecnico][:asiento_attributes]
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
      obj = ReglamentoTecnico.find(params[:id])

      if  params[:reglamento_tecnico][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "ReglamentoTecnico"
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

      #grabar objeto
      @reglamento_tecnico = tramite

      if @reglamento_tecnico.save
        flash.now[:success] = "Reglamento Técnico actualizado exitosamente"
        redirect_to asientos_path
        #redirect_to permisos_url
      else
        flash.now[:danger] = 'Reglamento Técnico no modificado, hay errores que corregir' 
        render :edit
      end
    end


end
