require 'test_helper'

class SancionsControllerTest < ActionController::TestCase
  setup do
    @sancion = sancions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sancions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sancion" do
    assert_difference('Sancion.count') do
      post :create, sancion: {  }
    end

    assert_redirected_to sancion_path(assigns(:sancion))
  end

  test "should show sancion" do
    get :show, id: @sancion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sancion
    assert_response :success
  end

  test "should update sancion" do
    patch :update, id: @sancion, sancion: {  }
    assert_redirected_to sancion_path(assigns(:sancion))
  end

  test "should destroy sancion" do
    assert_difference('Sancion.count', -1) do
      delete :destroy, id: @sancion
    end

    assert_redirected_to sancions_path
  end
end
