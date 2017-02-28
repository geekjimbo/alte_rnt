class OperadorReguladosController < ApplicationController
  
  PER_PAGE = 10

  def get_json
    operador = OperadorRegulado.find(params[:id])
    render :json => operador.to_json
  end

  def index
    @operador_regulados = OperadorRegulado.paginate(page: params[:page], per_page: PER_PAGE)
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

  def get_json
    @operador_regulado = OperadorRegulado.find(params[:id])
    render :text => @operador_regulado.to_json
  end

  private
    def set_operador_regulado
      @operador_regulado = OperadorRegulado.find(params[:id])
    end
    
    def operador_regulado_params
      params.require(:operador_regulado).permit(:nombre, :identificacion, :codigo_operador, :nombre_representante_legal, :cedula_representante_legal)
    end
end
