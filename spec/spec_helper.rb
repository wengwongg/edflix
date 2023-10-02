require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
end
SimpleCov.coverage_dir "coverage"

# Ensure we use the test database
ENV["APP_ENV"] = "test"

# load the app
require_relative "../app"

# load helpers
require_rel "helpers"

# Configure Capybara
require "capybara/rspec"
Capybara.app = Sinatra::Application

# Configure RSpec
require "rack/test"
require "rspec"

Capybara.app = Sinatra::Application
def app
  Sinatra::Application
end

def session
  last_request.env['rack.session']
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods
end
