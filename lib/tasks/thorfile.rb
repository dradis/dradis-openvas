class OpenVASTasks < Thor
  include Rails.application.config.dradis.thor_helper_module

  namespace "dradis:plugins:openvas"

  desc "upload FILE", "upload OpenVAS XML results"
  def upload(file_path)
    require 'config/environment'

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    unless File.exists?(file_path)
      $stderr.puts "** the file [#{file_path}] does not exist"
      exit -1
    end

    detect_and_set_project_scope

    importer = Dradis::Plugins::OpenVAS::Importer.new(logger: logger)
    importer.import(file: file_path)

    logger.close
  end

end
