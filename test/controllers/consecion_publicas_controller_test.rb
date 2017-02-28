require 'test_helper'

class ConsecionPublicasControllerTest < ActionController::TestCase
  setup do
    @consecion_publica = consecion_publicas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:consecion_publicas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create consecion_publica" do
    assert_difference('ConsecionPublica.count') do
      post :create, consecion_publica: {  }
    end

    assert_redirected_to consecion_publica_path(assigns(:consecion_publica))
  end

  test "should show consecion_publica" do
    get :show, id: @consecion_publica
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @consecion_publica
    assert_response :success
  end

  test "should update consecion_publica" do
    patch :update, id: @consecion_publica, consecion_publica: {  }
    assert_redirected_to consecion_publica_path(assigns(:consecion_publica))
  end

  test "should destroy consecion_publica" do
    assert_difference('ConsecionPublica.count', -1) do
      delete :destroy, id: @consecion_publica
    end

    assert_redirected_to consecion_publicas_path
  end
end
