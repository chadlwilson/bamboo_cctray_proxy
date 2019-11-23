require 'nokogiri'

RSpec::Matchers.define :have_project_tag_count do |expected_count|
  match do |report_xml|
    doc = Nokogiri::XML::Document.parse(report_xml)
    doc.xpath('Projects/Project').size.should eq(expected_count)
  end
end
