require 'test_helper'

class ConvenioPrivadosControllerTest < ActionController::TestCase
  setup do
    @convenio_privado = convenio_privados(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:convenio_privados)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create convenio_privado" do
    assert_difference('ConvenioPrivado.count') do
      post :create, convenio_privado: {  }
    end

    assert_redirected_to convenio_privado_path(assigns(:convenio_privado))
  end

  test "should show convenio_privado" do
    get :show, id: @convenio_privado
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @convenio_privado
    assert_response :success
  end

  test "should update convenio_privado" do
    patch :update, id: @convenio_privado, convenio_privado: {  }
    assert_redirected_to convenio_privado_path(assigns(:convenio_privado))
  end

  test "should destroy convenio_privado" do
    assert_difference('ConvenioPrivado.count', -1) do
      delete :destroy, id: @convenio_privado
    end

    assert_redirected_to convenio_privados_path
  end
end
