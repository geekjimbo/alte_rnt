require 'test_helper'

class SciServiciosControllerTest < ActionController::TestCase
  setup do
    @sci_servicio = sci_servicios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sci_servicios)
  end
end
