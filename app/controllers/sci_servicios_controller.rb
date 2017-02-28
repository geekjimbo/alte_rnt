class SciServiciosController < ApplicationController

  PER_PAGE = 10

  def index
    @sci_servicios = SciServicio.paginate(page: params[:page], per_page: PER_PAGE)
  end
  
  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sci_servicio
      @sci_servicio = SciServicio.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sci_servicio_params
      params.require(:sci_servicio).permit(:descripcion)
    end
end
