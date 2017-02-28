ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  #returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logs in a test user.
  def log_in_as(user, options={})
    password = options[:password] || 'colorado'
    if integration_test?
      post login_path, session: {email: user.email,
                                 password: password}
    else
      session[:user_id] = user_id
    end
  end

  private

    def integration_test?
      defined?(post_via_redirect)
    end
end
