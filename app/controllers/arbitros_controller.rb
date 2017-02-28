class ArbitrosController < ApplicationController
  
  PER_PAGE = 10

  def index
    @arbitros = Arbitro.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @arbitro = Arbitro.find(params[:id])
  end

  def new
    @operadores = OperadorRegulado.all.order('nombre')
    @arbitro = Arbitro.new
    @arbitro.build_asiento
    
    # load anatext if any
    @anatext_asiento = check_for_anatext @arbitro.asiento
    @arbitro.asiento = @anatext_asiento if !@anatext_asiento.nil?

    @asiento = @arbitro.asiento
    @arbitro.asiento.tipo_asiento = "AS"
    @arbitro.asiento.tipo_inscripcion = "Asiento Nuevo"
  end

  def edit
    @operadores = OperadorRegulado.all.order('nombre')
    @arbitro = Arbitro.find(params[:id])
    @asiento = @arbitro.asiento
    @arbitro.asiento.tipo_asiento = "ED"
    #@arbitro.asiento.tipo_inscripcion = "Modificación de Asiento"
  end

  def create
    set_asientos_fields
    @arbitro = Arbitro.new(arbitro_params)

    if !is_asiento_nil? 
      if @arbitro.save
        unless @consecutivo.nil? 
          @consecutivo.save
        end
        flash.now[:success] = "Arbitro creado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Arbitro no creado, hay errores que corregir' 
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
    Arbitro.find(params[:id]).destroy
    flash.now[:success] = "Arbitro borrado"
    redirect_to convenio_privados_url
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_arbitro
      @arbitro = Arbitro.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def arbitro_params
        unless params[:arbitro].empty? 
          params.require(:arbitro).permit(:nombre_acreditado, :identificacion_acreditado,:fecha_vencimiento, asiento_attributes: [:id, :acto_id, :acto_type, :_destroy, :num_asiento, :num_asiento_original, :acto_inscribible, :tipo_asiento, :tipo_inscripcion, :numero_resolucion, :nombre_resolucion,:titulo_resolucion, :titulo_resolucion, :fecha_resolucion, :fecha_solicitud, :nombre_operador, :identificacion_operador, :cedula_representante_legal, :nombre_representante_legal, :usuario, :enlace_documento, :num_expediente_sutel, :operadorregulado_id, :vigencia2 ])
        end
    end
    
    def is_asiento_nil?
      @arbitro.asiento.nil?
    end

    def set_asientos_fields
      rn = params[:arbitro][:asiento_attributes]
      unless rn.nil?
        if action_name == "create"
          rn[:num_asiento_original] = ""
          rn[:num_asiento] = obtener_numero_asiento("AS")
          rn[:tipo_inscripcion] = "Asiento Nuevo"
          rn[:tipo_asiento] = "AS"
          rn[:fecha_solicitud] = Time.now
        end

        rn[:nombre_operador] = " "
        rn[:identificacion_operador] = " "
        rn[:acto_inscribible] = "Arbitro"
        rn[:usuario] = current_user.id.to_s + "-" + current_user.email

        if action_name == 'update'
          clonar_objetos
        end
      end

    end

    def clonar
      neutro = params[:arbitro]
      asiento = Asiento.new
      tramite = Arbitro.new

      # copiar objeto padre existente
      neutro.each do |key, val|
        unless key == "asiento_attributes" 
          tramite[key] = val if key != "id"
        end
      end

      neutro = params[:arbitro][:asiento_attributes]
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

    def borrar_objetos(child)
      unless child.nil? 
        child.each do |c|
          c.destroy
        end
      end
    end

    def clonar_objetos
      tramite = clonar

      # generar nuevo id
      #@consecutivo = Consecutivo.find_by(md: false)
      #@consecutivo.md = true
      
      #intercambiar llaves
      obj = Arbitro.find(params[:id])

      if  params[:arbitro][:asiento_attributes][:tipo_asiento]== "MD"
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento
        tramite.asiento.num_asiento = obtener_numero_asiento("MD")
        tramite.asiento.tipo_asiento = "MD"
        tramite.asiento.tipo_inscripcion = "Modificación de Asiento"
        tramite.asiento.acto_type = "Arbitro"
      else
        tramite.asiento.num_asiento_original = obj.asiento.num_asiento_original
        tramite.asiento.num_asiento = obj.asiento.num_asiento
        tramite.asiento.tipo_asiento = obj.asiento.tipo_asiento
        tramite.asiento.tipo_inscripcion = obj.asiento.tipo_inscripcion
        tramite.asiento.acto_type = obj.asiento.acto_type
        tramite.asiento.acto_inscribible = obj.asiento.acto_inscribible
        tramite.asiento.fecha_solicitud = obj.asiento.fecha_solicitud

        #borrar objetos
        obj.destroy
      end
      #grabar objeto
      
      parametros = params[:arbitro][:asiento_attributes]

      @arbitro = tramite

      if @arbitro.save
        @consecutivo.save if !@consecutivo.nil?
        flash.now[:success] = "Arbitro actualizado exitosamente"
        redirect_to asientos_path
      else
        flash.now[:danger] = 'Arbitro no modificado, hay errores que corregir' 
        render :edit
      end
  end
end
