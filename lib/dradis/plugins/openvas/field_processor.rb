module Dradis::Plugins::OpenVAS

  # This processor defers to ::OpenVAS::Result class to extract all the
  # relevant information exposed through the :result template.
  class FieldProcessor < Dradis::Plugins::Upload::FieldProcessor

    def post_initialize(args={})

      # Figure out if v6 or v7
      @openvas_object = case detect_version(data)
                        when :v6
                          ::OpenVAS::V6::Result.new(data)
                        when :v7
                          ::OpenVAS::V7::Result.new(data)
                        end
    end

    def value(args={})
      field = args[:field]

      # fields in the template are of the form <foo>.<field>, where <foo>
      # is common across all fields for a given template (and meaningless).
      _, name = field.split('.')

      @openvas_object.try(name) || 'n/a'
    end

    private
    # There is no clear-cut way to determine the version of the file from the
    # contents (see thread below) so we have to do some guess work.
    #
    # See:
    #   http://lists.wald.intevation.org/pipermail/openvas-discuss/2014-October/006907.html
    #   http://lists.wald.intevation.org/pipermail/openvas-discuss/2014-November/007092.html
    def detect_version(xml_data)
      # Gross over simplification. May need to smarten in the future.
      xml_data.at_xpath('./description[contains(text(), "Summary:")]') ? :v6 : :v7
    end

  end

end
