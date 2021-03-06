require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "", email: "user@invalid", 
                               password: "foo", password_confirmation: "bar" }
    end
    assert_template 'users/new'
  end
  
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name: "Sample User", email: "user@valid.org", 
                               password: "foo", password_confirmation: "foo" }
    end
    follow_redirect! # the get statement doesn't follow redirect, must force it
    assert_template 'users/show'
    assert is_logged_in?
  end
end
