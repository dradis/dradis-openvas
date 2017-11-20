require 'spec_helper'

  describe 'OpenVAS upload plugin' do
    before(:each) do
      # Stub template service
      templates_dir = File.expand_path('../../../templates', __FILE__)
      expect_any_instance_of(Dradis::Plugins::TemplateService)
      .to receive(:default_templates_dir).and_return(templates_dir)

      # Init services
      plugin = Dradis::Plugins::OpenVAS

      @content_service = Dradis::Plugins::ContentService::Base.new(
        logger: Logger.new(STDOUT),
        plugin: plugin
      )

      @importer = Dradis::Plugins::OpenVAS::Importer.new(
        content_service: @content_service
      )

      # Stub dradis-plugins methods
      #
      # They return their argument hashes as objects mimicking
      # Nodes, Issues, etc
      allow(@content_service).to receive(:create_node) do |args|
        obj = OpenStruct.new(args)
        obj.define_singleton_method(:set_property) { |_, __| }
        obj
      end
      allow(@content_service).to receive(:create_issue) do |args|
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_evidence) do |args|
        OpenStruct.new(args)
      end
    end

    it "creates issues and evidence as expected" do
      # splits the <tags> into the correct component fields
      # respects paragraphs within the component fields of <tags>
      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include("#[Title]#\nOpenSSL CCS Man in the Middle Security Bypass Vulnerability")
        expect(args[:text]).to include("#[Description]#\nOpenSSL is prone to security-bypass vulnerability.")
        expect(args[:text]).to include("#[Recommendation]#\nUpdates are available.")
        expect(args[:text]).to include("#[Insight]#\nOpenSSL does not properly restrict processing of ChangeCipherSpec\nmessages, which allows man-in-the-middle attackers to trigger use of a\nzero-length master key in certain OpenSSL-to-OpenSSL communications, and\nconsequently hijack sessions or obtain sensitive information, via a crafted\nTLS handshake, aka the 'CCS Injection' vulnerability.")
        expect(args[:text]).to include("#[Detection]#\nSend two SSL ChangeCipherSpec request and check the response.")
        OpenStruct.new(args)
      end
      # pulls threat and severity down to the Evidence level
      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include("#[Threat]#\nMedium")
        expect(args[:content]).to include("#[Severity]#\n6.8")
        expect(args[:issue].text).to include("#[Title]#\nOpenSSL CCS Man in the Middle Security Bypass Vulnerability")
        expect(args[:node].label).to eq("10.10.10.10")
      end

      @importer.import(file: 'spec/fixtures/files/v7/report_v7.xml')
    end

  end
