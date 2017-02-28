require 'test_helper'

class ReglamentoTecnicosControllerTest < ActionController::TestCase
  setup do
    @reglamento_tecnico = reglamento_tecnicos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reglamento_tecnicos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reglamento_tecnico" do
    assert_difference('ReglamentoTecnico.count') do
      post :create, reglamento_tecnico: {  }
    end

    assert_redirected_to reglamento_tecnico_path(assigns(:reglamento_tecnico))
  end

  test "should show reglamento_tecnico" do
    get :show, id: @reglamento_tecnico
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @reglamento_tecnico
    assert_response :success
  end

  test "should update reglamento_tecnico" do
    patch :update, id: @reglamento_tecnico, reglamento_tecnico: {  }
    assert_redirected_to reglamento_tecnico_path(assigns(:reglamento_tecnico))
  end

  test "should destroy reglamento_tecnico" do
    assert_difference('ReglamentoTecnico.count', -1) do
      delete :destroy, id: @reglamento_tecnico
    end

    assert_redirected_to reglamento_tecnicos_path
  end
end
