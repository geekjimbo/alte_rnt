require 'test_helper'

class UsersLogoutTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:john)
  end
  
  test "login with valid information followed by logout succesfully" do

    #login
    get login_path
    assert_template 'sessions/new'

    post login_path, session: {email: @user.email, password: 'colorado'} 
    assert is_logged_in?

    assert_redirected_to @user    
    follow_redirect! # the get statement doesn't follow redirect, must force it
    assert_template 'users/show'

    # logout
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # simulate a user clicking logout in a second window.
    delete logout_path

    follow_redirect!
    assert_select "a[href=?", login_path
    assert_select "a[href=?", logout_path, count: 0
    assert_select "a[href=?", user_path(@user), count: 0
  end
end
