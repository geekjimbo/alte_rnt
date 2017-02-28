require 'test_helper'

class ConsecionAnteriorsControllerTest < ActionController::TestCase
  setup do
    @consecion_anterior = consecion_anteriors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:consecion_anteriors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create consecion_anterior" do
    assert_difference('ConsecionAnterior.count') do
      post :create, consecion_anterior: {  }
    end

    assert_redirected_to consecion_anterior_path(assigns(:consecion_anterior))
  end

  test "should show consecion_anterior" do
    get :show, id: @consecion_anterior
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @consecion_anterior
    assert_response :success
  end

  test "should update consecion_anterior" do
    patch :update, id: @consecion_anterior, consecion_anterior: {  }
    assert_redirected_to consecion_anterior_path(assigns(:consecion_anterior))
  end

  test "should destroy consecion_anterior" do
    assert_difference('ConsecionAnterior.count', -1) do
      delete :destroy, id: @consecion_anterior
    end

    assert_redirected_to consecion_anteriors_path
  end
end
