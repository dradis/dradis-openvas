require 'rubygems'
require 'bundler/setup'
require 'nokogiri'

require 'combustion'

Combustion.initialize!

RSpec.configure do |config|
end

require 'support/fixture_loader'
