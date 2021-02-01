module Dradis::Plugins::OpenVAS
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::OpenVAS

    include ::Dradis::Plugins::Base
    description 'Processes OpenVAS XML v6 or v7 format'
    provides :upload

    initializer "openvas.inflections" do |app|
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.acronym('OpenVAS')
      end
    end
  end
end