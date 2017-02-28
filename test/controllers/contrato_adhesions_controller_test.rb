require 'test_helper'

class ContratoAdhesionsControllerTest < ActionController::TestCase
  setup do
    @contrato_adhesion = contrato_adhesions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contrato_adhesions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contrato_adhesion" do
    assert_difference('ContratoAdhesion.count') do
      post :create, contrato_adhesion: {  }
    end

    assert_redirected_to contrato_adhesion_path(assigns(:contrato_adhesion))
  end

  test "should show contrato_adhesion" do
    get :show, id: @contrato_adhesion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contrato_adhesion
    assert_response :success
  end

  test "should update contrato_adhesion" do
    patch :update, id: @contrato_adhesion, contrato_adhesion: {  }
    assert_redirected_to contrato_adhesion_path(assigns(:contrato_adhesion))
  end

  test "should destroy contrato_adhesion" do
    assert_difference('ContratoAdhesion.count', -1) do
      delete :destroy, id: @contrato_adhesion
    end

    assert_redirected_to contrato_adhesions_path
  end
end
