require 'test_helper'

class SancionImpuestaControllerTest < ActionController::TestCase
  setup do
    @sancion_impuestum = sancion_impuesta(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sancion_impuesta)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sancion_impuestum" do
    assert_difference('SancionImpuestum.count') do
      post :create, sancion_impuestum: {  }
    end

    assert_redirected_to sancion_impuestum_path(assigns(:sancion_impuestum))
  end

  test "should show sancion_impuestum" do
    get :show, id: @sancion_impuestum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sancion_impuestum
    assert_response :success
  end

  test "should update sancion_impuestum" do
    patch :update, id: @sancion_impuestum, sancion_impuestum: {  }
    assert_redirected_to sancion_impuestum_path(assigns(:sancion_impuestum))
  end

  test "should destroy sancion_impuestum" do
    assert_difference('SancionImpuestum.count', -1) do
      delete :destroy, id: @sancion_impuestum
    end

    assert_redirected_to sancion_impuesta_path
  end
end
