class DradisTasks < Thor
  class Upload < Thor
include Core::Pro::ProjectScopedTask
    namespace     "dradis:upload"

    desc "openvas FILE", "upload OpenVAS results"
    def openvas(file_path)
      require 'config/environment'

      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG

      unless File.exists?(file_path)
        $stderr.puts "** the file [#{file_path}] does not exist"
        exit -1
      end

detect_and_set_project_scope

      content_service = nil
      template_service = nil
      if defined?(Dradis::Pro)
        content_service = Dradis::Pro::Plugins::ContentService.new(plugin: Dradis::Plugins::Acunetix)
        template_service = Dradis::Pro::Plugins::TemplateService.new(plugin: Dradis::Plugins::Acunetix)
      else
        content_service = Dradis::Plugins::ContentService.new(plugin: Dradis::Plugins::Acunetix)
        template_service = Dradis::Plugins::TemplateService.new(plugin: Dradis::Plugins::Acunetix)
      end

      importer = Dradis::Plugins::Acunetix::Importer.new(
                  logger: logger,
         content_service: content_service,
        template_service: template_service
      )

      importer.import(file: file_path)

      logger.close
    end

  end
end
