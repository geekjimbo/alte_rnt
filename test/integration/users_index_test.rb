require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:john)
  end

  test "index including pagination" do
    log_in_as @user
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    # User.paginate(page: 1).each do |user|
    #  assert_select 'a[href=?]', user_path(user), text: user.name
    # end
  end

  test "index delete links" do
    log_in_as @user
    get users_path
    assert_select 'div.pagination'
    
    assert_difference 'User.count', -1 do
      delete user_path @user
    end
  end
end
