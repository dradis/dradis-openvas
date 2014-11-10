module Dradis
  module Plugins
    module OpenVAS
      # This is required while we transition the Upload Manager to use
      # Dradis::Plugins only
      module Meta
        NAME = "OpenVAS XML upload plugin"
        EXPECTS = "OpenVAS XML v6 or v7 format."
        module VERSION
          include Dradis::Plugins::OpenVAS::VERSION
        end
      end
    end
  end
end

require 'dradis/plugins/openvas/engine'
require 'dradis/plugins/openvas/field_processor'
require 'dradis/plugins/openvas/importer'
require 'dradis/plugins/openvas/version'
