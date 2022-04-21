require 'spec_helper'

describe 'Openvas upload plugin' do
  describe 'importer' do
    before(:each) do
      # Stub template service
      templates_dir = File.expand_path('../../../templates', __FILE__)
      expect_any_instance_of(Dradis::Plugins::TemplateService)
      .to receive(:default_templates_dir).and_return(templates_dir)

      plugin = Dradis::Plugins::OpenVAS

      @content_service = Dradis::Plugins::ContentService::Base.new(plugin: plugin)

      allow(@content_service).to receive(:create_note) do |args|
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_node) do |args|
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_issue) do |args|
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_evidence) do |args|
        OpenStruct.new(args)
      end

      @importer = plugin::Importer.new(
        content_service: @content_service
      )
    end

    context 'Openvas v24 output' do
      it 'parses node label without hostname' do
        expect(@content_service).to receive(:create_node) do |args|
          expect(args[:label]).to eq('188.111.11.85')
          expect(args[:type]).to eq(:host)
        end

        @importer.import(file: File.expand_path('../fixtures/files/report_v24.xml', __dir__))
      end
    end
  end
end
