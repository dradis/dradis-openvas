module Dradis::Plugins::OpenVAS
  class Importer < Dradis::Plugins::Upload::Importer

    # The framework will call this function if the user selects this plugin from
    # the dropdown list and uploads a file.
    # @returns true if the operation was successful, false otherwise
    def import(params={})
      file_content = File.read( params[:file] )

      # Parse contents
      logger.info{'Parsing OpenVAS output file...'}
      @doc = Nokogiri::XML(file_content)
      logger.info{'Done'}


      # Detect valid OpenVAS XML
      if @doc.xpath('/report').empty?
        error = "No report results were detected in the uploaded file (/report). Ensure you uploaded an OpenVAS XML report."
        logger.fatal{ error }
        content_service.create_note text: error
        return false
      end


      @doc.xpath('/report/report/results/result').each do |xml_result|
        process_result(xml_result)
      end

      logger.info{ "Report processed." }
      return true
    end

    private
    attr_accessor :host_node

    def process_result(xml_result)
      # Extract host
      set_host(xml_result.at_xpath('./host'))

      # Uniquely identify this issue
      nvt_oid = xml_result.at_xpath('./nvt')[:oid]

      logger.info{ "\t\t => Creating new issue (#{nvt_oid})" }

      issue_text = template_service.process_template(template: 'result', data: xml_result)
      issue = content_service.create_issue(text: issue_text, id: nvt_oid)


      # Add evidence. It doesn't look like OpenVAS provides much in terms of
      # instance-specific evidence though.
      logger.info{ "\t\t => Adding reference to this host" }

      # There is no way of knowing where OpenVAS is going to place the evidence
      # for each issue. For example:
      #
      # A) 1.3.6.1.4.1.25623.1.0.900498 - 'Apache Web ServerVersion Detection'
      # uses the full <description> field:
      #
      #      <description>Detected Apache Tomcat version: 2.2.22
      #       Location: 80/tcp
      #       CPE: cpe:/a:apache:http_server:2.2.22
      #
      #       Concluded from version identification result:
      #       Server: Apache/2.2.22
      #      </description>
      #
      # B) 1.3.6.1.4.1.25623.1.0.103122 - 'Apache Web Server ETag Header
      # Information Disclosure Weakness' uses the 'Information that was gathered'
      # meta-field inside <description>
      #
      #      <description>
      #         Summary:
      #         A weakness has been discovered in Apache web servers that are
      #        configured to use the FileETag directive. Due to the way in which
      #        [...]
      #
      #         Solution:
      #         OpenBSD has released a patch to address this issue.
      #        [...]
      #
      #        Information that was gathered:
      #        Inode: 5753015
      #        Size: 604
      #        </description>
      #
      # C) 1.3.6.1.4.1.25623.1.0.10766 - 'Apache UserDir Sensitive Information Disclosure'
      # doesn't provide any per-instance information.
      #
      # Best thing to do is to include the full <description> field and let the user deal with it.
      
      evidence_content = template_service.process_template(template: 'evidence', data: xml_result)
      content_service.create_evidence(issue: issue, node: host_node, content: evidence_content)
    end

    def set_host(xml_host)
      host_label = xml_host.at_xpath('text()').text
      self.host_node = content_service.create_node(label: host_label, type: :host)

      xml_hostname = xml_host.at_xpath('./hostname')
      host_node.set_property(:hostname, xml_hostname.text) if xml_hostname

      xml_asset = xml_host.at_xpath('./asset')
      host_node.set_property(:asset_id, xml_asset[:asset_id]) if xml_asset

      host_node.save!
    end

  end
end
