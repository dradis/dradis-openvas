module FixtureLoader
  def load_fixture_file(file_name)
    Nokogiri::XML( File.read("spec/fixtures/files/#{file_name}") )
  end
end