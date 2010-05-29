require 'nokogiri'

Spec::Matchers.define :have_project_tag_count do |expected_count|
  match do |report_xml|
    doc = Nokogiri::XML::Document.parse(report_xml)
    doc.xpath('Projects/Project').should have(expected_count).result
  end
end
