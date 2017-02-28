class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :delete, :destroy]
  
  PER_PAGE = 10

  def index
    @users = User.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Bienvenido(a) al RNT"
      redirect_to asientos_path
    else
      flash[:danger] = 'Combinación inválida de email/password' 
      render :new
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Perfil actualizado exitosamente!"
      redirect_to asientos_path
      # handle successful update
    else
      flash[:danger] = 'Hay errores reportados durante tus cambios' 
      # render 'edit'
      render :edit
    end
  end

  def delete
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Usuario borrado!"
    redirect_to users_url
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, 
                                   :password_confirmation)
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Por favor ingresá con tu usuario!"
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to asientos_path unless @user == current_user
    end
end
