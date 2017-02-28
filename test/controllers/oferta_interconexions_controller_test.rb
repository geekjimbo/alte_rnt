require 'test_helper'

class OfertaInterconexionsControllerTest < ActionController::TestCase
  setup do
    @oferta_interconexion = oferta_interconexions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:oferta_interconexions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create oferta_interconexion" do
    assert_difference('OfertaInterconexion.count') do
      post :create, oferta_interconexion: {  }
    end

    assert_redirected_to oferta_interconexion_path(assigns(:oferta_interconexion))
  end

  test "should show oferta_interconexion" do
    get :show, id: @oferta_interconexion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @oferta_interconexion
    assert_response :success
  end

  test "should update oferta_interconexion" do
    patch :update, id: @oferta_interconexion, oferta_interconexion: {  }
    assert_redirected_to oferta_interconexion_path(assigns(:oferta_interconexion))
  end

  test "should destroy oferta_interconexion" do
    assert_difference('OfertaInterconexion.count', -1) do
      delete :destroy, id: @oferta_interconexion
    end

    assert_redirected_to oferta_interconexions_path
  end
end
