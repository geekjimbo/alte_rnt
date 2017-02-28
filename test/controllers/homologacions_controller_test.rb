require 'test_helper'

class HomologacionsControllerTest < ActionController::TestCase
  setup do
    @homologacion = homologacions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:homologacions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create homologacion" do
    assert_difference('Homologacion.count') do
      post :create, homologacion: {  }
    end

    assert_redirected_to homologacion_path(assigns(:homologacion))
  end

  test "should show homologacion" do
    get :show, id: @homologacion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @homologacion
    assert_response :success
  end

  test "should update homologacion" do
    patch :update, id: @homologacion, homologacion: {  }
    assert_redirected_to homologacion_path(assigns(:homologacion))
  end

  test "should destroy homologacion" do
    assert_difference('Homologacion.count', -1) do
      delete :destroy, id: @homologacion
    end

    assert_redirected_to homologacions_path
  end
end
