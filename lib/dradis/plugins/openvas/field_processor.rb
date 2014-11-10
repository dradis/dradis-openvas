module Dradis::Plugins::OpenVAS

  # This processor defers to ::OpenVAS::Result class to extract all the
  # relevant information exposed through the :result template.
  class FieldProcessor < Dradis::Plugins::Upload::FieldProcessor

    def post_initialize(args={})
      @openvas_object = ::OpenVAS::Scan.new(data)
    end

    def value(args={})
      field = args[:field]

      # fields in the template are of the form <foo>.<field>, where <foo>
      # is common across all fields for a given template (and meaningless).
      _, name = field.split('.')

      @openvas_object.try(name) || 'n/a'
    end
  end

end
