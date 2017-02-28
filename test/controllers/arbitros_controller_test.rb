require 'test_helper'

class ArbitrosControllerTest < ActionController::TestCase
  setup do
    @arbitro = arbitros(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:arbitros)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create arbitro" do
    assert_difference('Arbitro.count') do
      post :create, arbitro: {  }
    end

    assert_redirected_to arbitro_path(assigns(:arbitro))
  end

  test "should show arbitro" do
    get :show, id: @arbitro
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @arbitro
    assert_response :success
  end

  test "should update arbitro" do
    patch :update, id: @arbitro, arbitro: {  }
    assert_redirected_to arbitro_path(assigns(:arbitro))
  end

  test "should destroy arbitro" do
    assert_difference('Arbitro.count', -1) do
      delete :destroy, id: @arbitro
    end

    assert_redirected_to arbitros_path
  end
end
