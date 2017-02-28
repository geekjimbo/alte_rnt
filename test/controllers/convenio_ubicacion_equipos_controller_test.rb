require 'test_helper'

class ConvenioUbicacionEquiposControllerTest < ActionController::TestCase
  setup do
    @convenio_ubicacion_equipo = convenio_ubicacion_equipos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:convenio_ubicacion_equipos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create convenio_ubicacion_equipo" do
    assert_difference('ConvenioUbicacionEquipo.count') do
      post :create, convenio_ubicacion_equipo: {  }
    end

    assert_redirected_to convenio_ubicacion_equipo_path(assigns(:convenio_ubicacion_equipo))
  end

  test "should show convenio_ubicacion_equipo" do
    get :show, id: @convenio_ubicacion_equipo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @convenio_ubicacion_equipo
    assert_response :success
  end

  test "should update convenio_ubicacion_equipo" do
    patch :update, id: @convenio_ubicacion_equipo, convenio_ubicacion_equipo: {  }
    assert_redirected_to convenio_ubicacion_equipo_path(assigns(:convenio_ubicacion_equipo))
  end

  test "should destroy convenio_ubicacion_equipo" do
    assert_difference('ConvenioUbicacionEquipo.count', -1) do
      delete :destroy, id: @convenio_ubicacion_equipo
    end

    assert_redirected_to convenio_ubicacion_equipos_path
  end
end
