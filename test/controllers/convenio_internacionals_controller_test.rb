require 'test_helper'

class ConvenioInternacionalsControllerTest < ActionController::TestCase
  setup do
    @convenio_internacional = convenio_internacionals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:convenio_internacionals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create convenio_internacional" do
    assert_difference('ConvenioInternacional.count') do
      post :create, convenio_internacional: {  }
    end

    assert_redirected_to convenio_internacional_path(assigns(:convenio_internacional))
  end

  test "should show convenio_internacional" do
    get :show, id: @convenio_internacional
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @convenio_internacional
    assert_response :success
  end

  test "should update convenio_internacional" do
    patch :update, id: @convenio_internacional, convenio_internacional: {  }
    assert_redirected_to convenio_internacional_path(assigns(:convenio_internacional))
  end

  test "should destroy convenio_internacional" do
    assert_difference('ConvenioInternacional.count', -1) do
      delete :destroy, id: @convenio_internacional
    end

    assert_redirected_to convenio_internacionals_path
  end
end
