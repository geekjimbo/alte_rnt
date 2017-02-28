require 'test_helper'

class RecursoNumericosControllerTest < ActionController::TestCase
  setup do
    @recurso_numerico = recurso_numericos(:one)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create recurso_numerico" do
    assert_difference('RecursoNumerico.count') do
      post :create, recurso_numerico: {  }
    end

    assert_redirected_to recurso_numerico_path(assigns(:recurso_numerico))
  end

  test "should get edit" do
    get :edit, id: @recurso_numerico
    assert_response :success
  end

  test "should update recurso_numerico" do
    patch :update, id: @recurso_numerico, recurso_numerico: {  }
    assert_redirected_to recurso_numerico_path(assigns(:recurso_numerico))
  end

  test "should destroy recurso_numerico" do
    assert_difference('RecursoNumerico.count', -1) do
      delete :destroy, id: @recurso_numerico
    end
    assert_redirected_to recurso_numericos_path
  end
end
