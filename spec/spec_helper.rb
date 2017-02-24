$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "factory_lite"
require "pry"

RSpec.configure do |config|
  config.filter_run_when_matching :focus
end
