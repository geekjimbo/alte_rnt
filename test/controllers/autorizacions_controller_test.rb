require 'test_helper'

class AutorizacionsControllerTest < ActionController::TestCase
  setup do
    @autorizacion = autorizacions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:autorizacions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create autorizacion" do
    assert_difference('Autorizacion.count') do
      post :create, autorizacion: {  }
    end

    assert_redirected_to autorizacion_path(assigns(:autorizacion))
  end

  test "should show autorizacion" do
    get :show, id: @autorizacion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @autorizacion
    assert_response :success
  end

  test "should update autorizacion" do
    patch :update, id: @autorizacion, autorizacion: {  }
    assert_redirected_to autorizacion_path(assigns(:autorizacion))
  end

  test "should destroy autorizacion" do
    assert_difference('Autorizacion.count', -1) do
      delete :destroy, id: @autorizacion
    end

    assert_redirected_to autorizacions_path
  end
end
