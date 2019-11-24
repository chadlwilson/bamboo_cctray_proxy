require 'nokogiri'

RSpec::Matchers.define :have_project_tags do |*expected_project_tags|
  match do |report_xml|
    doc = Nokogiri::XML::Document.parse(report_xml)
    expect(doc.xpath('Projects/Project').size).to eq(expected_project_tags.size)
    
    result = true
    doc.xpath('Projects/Project').each_with_index do |actual_tag, index|
      actual_tag_attributes = actual_tag.attributes
      expected_project_tags[index].each_pair do |attribute, value|
        result &&= (actual_tag_attributes[attribute].text == value)
      end
    end
    result
  end
  
  failure_message do |report_xml|
    "expected #{report_xml} tag to have project tag attributes #{expected_project_tags.inspect}"
  end

  failure_message_when_negated do |report_xml|
    "expected #{report_xml} tag to not have project tag attributes #{expected_project_tags.inspect}"
  end
end
