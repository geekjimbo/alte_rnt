require 'test_helper'

class OperadorReguladosControllerTest < ActionController::TestCase
  setup do
    @operador_regulado = operador_regulados(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:operador_regulados)
  end

end
