require 'capybara/rspec'
require_relative '../app'  # Adjust the path to your Sinatra app

Capybara.app = Sinatra::Application

RSpec.configure do |config|
  config.include Capybara::DSL
end