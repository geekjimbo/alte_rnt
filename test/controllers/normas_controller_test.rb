require 'test_helper'

class NormasControllerTest < ActionController::TestCase
  setup do
    @norma = normas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:normas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create norma" do
    assert_difference('Norma.count') do
      post :create, norma: {  }
    end

    assert_redirected_to norma_path(assigns(:norma))
  end

  test "should show norma" do
    get :show, id: @norma
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @norma
    assert_response :success
  end

  test "should update norma" do
    patch :update, id: @norma, norma: {  }
    assert_redirected_to norma_path(assigns(:norma))
  end

  test "should destroy norma" do
    assert_difference('Norma.count', -1) do
      delete :destroy, id: @norma
    end

    assert_redirected_to normas_path
  end
end
