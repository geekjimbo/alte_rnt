require 'test_helper'

class FonatelsControllerTest < ActionController::TestCase
  setup do
    @fonatel = fonatels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fonatels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fonatel" do
    assert_difference('Fonatel.count') do
      post :create, fonatel: {  }
    end

    assert_redirected_to fonatel_path(assigns(:fonatel))
  end

  test "should show fonatel" do
    get :show, id: @fonatel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fonatel
    assert_response :success
  end

  test "should update fonatel" do
    patch :update, id: @fonatel, fonatel: {  }
    assert_redirected_to fonatel_path(assigns(:fonatel))
  end

  test "should destroy fonatel" do
    assert_difference('Fonatel.count', -1) do
      delete :destroy, id: @fonatel
    end

    assert_redirected_to fonatels_path
  end
end
