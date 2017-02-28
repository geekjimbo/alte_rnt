require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "RNT app"
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Ayuda | RNT app"
  end

  test "should get about" do
    get :about
    assert_response :success
    assert_select "title", "Acerca de | RNT app"
  end
  
  test "should get contact" do
    get :contact
    assert_response :success
    assert_select "title", "Contacto | RNT app"
  end
end
