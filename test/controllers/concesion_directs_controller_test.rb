require 'test_helper'

class ConcesionDirectsControllerTest < ActionController::TestCase
  setup do
    @concesion_direct = concesion_directs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:concesion_directs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create concesion_direct" do
    assert_difference('ConcesionDirect.count') do
      post :create, concesion_direct: {  }
    end

    assert_redirected_to concesion_direct_path(assigns(:concesion_direct))
  end

  test "should show concesion_direct" do
    get :show, id: @concesion_direct
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @concesion_direct
    assert_response :success
  end

  test "should update concesion_direct" do
    patch :update, id: @concesion_direct, concesion_direct: {  }
    assert_redirected_to concesion_direct_path(assigns(:concesion_direct))
  end

  test "should destroy concesion_direct" do
    assert_difference('ConcesionDirect.count', -1) do
      delete :destroy, id: @concesion_direct
    end

    assert_redirected_to concesion_directs_path
  end
end
