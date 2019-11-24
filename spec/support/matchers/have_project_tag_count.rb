require 'nokogiri'

RSpec::Matchers.define :have_project_tag_count do |expected_count|
  match do |report_xml|
    doc = Nokogiri::XML::Document.parse(report_xml)
    expect(doc.xpath('Projects/Project').size).to eq(expected_count)
  end
end
