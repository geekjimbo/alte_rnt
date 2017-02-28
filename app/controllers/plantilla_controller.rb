class PermisosController < ApplicationController

  PER_PAGE = 10
  
  def index
    @permisos = Permiso.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @permiso = Permiso.find(params[:id])
  end

  def new
    @permiso = Permiso.new
    @permiso.build_tramite
  end

  def edit
    @permiso = Permiso.find(params[:id])
  end

  def create
    @permiso = Permiso.new(permiso_params)
    if !is_tramite_nil?
      if @permiso.save
        flash.now[:success] = "Permiso creado exitosamente"
        #redirect_to permisos_url
        render 'edit'
      end
    else
      flash.now[:danger] = 'Permiso no creado, hay errores que corregir' 
      @permiso.build_tramite
      render 'new'
    end
  end

  def update
    @permiso = Permiso.find(params[:id])
    if @permiso.update_attributes(permiso_params)
      flash.now[:success] = "Permiso modificado exitosamente"
      #redirect_to permisos_url
    else
      flash.now[:danger] = 'Permiso no modificado, hay errores que corregir' 
    end
    render 'edit'
  end
  
  def delete
  end

  def destroy
    Permiso.find(params[:id]).destroy
    flash.now[:success] = "Permiso borrado"
    redirect_to permisos_url
  end

  private
    
    def permiso_params
      params.require(:permiso).permit(:regulado, tramite_attributes: [:id, :perfil_id, :perfil_type, :descripcion, :_destroy])
    end

    def is_tramite_nil?
      @permiso.tramite.nil?
    end
end
