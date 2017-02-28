require 'test_helper'

class ResolucionUbicacionEquiposControllerTest < ActionController::TestCase
  setup do
    @resolucion_ubicacion_equipo = resolucion_ubicacion_equipos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resolucion_ubicacion_equipos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resolucion_ubicacion_equipo" do
    assert_difference('ResolucionUbicacionEquipo.count') do
      post :create, resolucion_ubicacion_equipo: {  }
    end

    assert_redirected_to resolucion_ubicacion_equipo_path(assigns(:resolucion_ubicacion_equipo))
  end

  test "should show resolucion_ubicacion_equipo" do
    get :show, id: @resolucion_ubicacion_equipo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resolucion_ubicacion_equipo
    assert_response :success
  end

  test "should update resolucion_ubicacion_equipo" do
    patch :update, id: @resolucion_ubicacion_equipo, resolucion_ubicacion_equipo: {  }
    assert_redirected_to resolucion_ubicacion_equipo_path(assigns(:resolucion_ubicacion_equipo))
  end

  test "should destroy resolucion_ubicacion_equipo" do
    assert_difference('ResolucionUbicacionEquipo.count', -1) do
      delete :destroy, id: @resolucion_ubicacion_equipo
    end

    assert_redirected_to resolucion_ubicacion_equipos_path
  end
end
