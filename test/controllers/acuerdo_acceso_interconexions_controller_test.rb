require 'test_helper'

class AcuerdoAccesoInterconexionsControllerTest < ActionController::TestCase
  setup do
    @acuerdo_acceso_interconexion = acuerdo_acceso_interconexions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:acuerdo_acceso_interconexions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create acuerdo_acceso_interconexion" do
    assert_difference('AcuerdoAccesoInterconexion.count') do
      post :create, acuerdo_acceso_interconexion: {  }
    end

    assert_redirected_to acuerdo_acceso_interconexion_path(assigns(:acuerdo_acceso_interconexion))
  end

  test "should show acuerdo_acceso_interconexion" do
    get :show, id: @acuerdo_acceso_interconexion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @acuerdo_acceso_interconexion
    assert_response :success
  end

  test "should update acuerdo_acceso_interconexion" do
    patch :update, id: @acuerdo_acceso_interconexion, acuerdo_acceso_interconexion: {  }
    assert_redirected_to acuerdo_acceso_interconexion_path(assigns(:acuerdo_acceso_interconexion))
  end

  test "should destroy acuerdo_acceso_interconexion" do
    assert_difference('AcuerdoAccesoInterconexion.count', -1) do
      delete :destroy, id: @acuerdo_acceso_interconexion
    end

    assert_redirected_to acuerdo_acceso_interconexions_path
  end
end
