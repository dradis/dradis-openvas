require 'spec_helper'

describe Openvas::Result do
  include FixtureLoader

  it "splits the <description> tag in its component fields" do
    xml_doc = load_fixture_file('result.xml')
    result = Openvas::Result.new( xml_doc.at_xpath('/result') )
    result.description.should eq(xml_doc.at_xpath('/result/description').text)

    expect(result.summary).to eq("This host is installed with Oracle Java SE JRE and is prone to\nmultiple vulnerabilities.\n\n")
    expect(result.insight).to eq("Multiple flaws are caused by unspecified errors in the following\ncomponents:\n- 2D\n- AWT\n- Sound\n- I18n\n- CORBA\n- Serialization\n\n")
  end

  it "respects paragraphs within the component fields of the <description> value" do
    xml_doc = load_fixture_file('result2.xml')
    result = Openvas::Result.new( xml_doc.at_xpath('/result') )
    result.summary.should eq("A weakness has been discovered in Apache web servers that are\nconfigured to use the FileETag directive. Due to the way in which\nApache generates ETag response headers, it may be possible for an\nattacker to obtain sensitive information regarding server files.\nSpecifically, ETag header fields returned to a client contain the\nfile's inode number.\n\nExploitation of this issue may provide an attacker with information\nthat may be used to launch further attacks against a target network.\n\nOpenBSD has released a patch that addresses this issue. Inode numbers\nreturned from the server are now encoded using a private hash to avoid\nthe release of sensitive information.\n")
  end

  it "correctly parses the fringe 'Impact Level' case" do
    xml_doc = load_fixture_file('result.xml')
    result = Openvas::Result.new( xml_doc.at_xpath('/result') )

    result.impact_level.should eq('System/Application')
  end


  it "correctly parses the last component field in the <description>" do
    xml_doc = load_fixture_file('result2.xml')
    result = Openvas::Result.new( xml_doc.at_xpath('/result') )

    result.info_gathered.should eq("Inode: 1050855\nSize: 177\n\n")
  end
end