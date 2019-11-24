require 'model/project_build'
require 'date'

module ObjectFactory
  def create_project_build(params = {})
    default_params = {
      :name => 'FAKEPROJ-MYPROJ',
      :activity => :sleeping,
      :last_build_status => :success,
      :last_build_label => '39',
      :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    }
    
    ProjectBuild.new(default_params.merge(params))
  end
  
  def create_feed_xml(*params)
    result = %Q(
    <?xml version="1.0" encoding="UTF-8"?>
    <rss xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:taxo="http://purl.org/rss/1.0/modules/taxonomy/" version="2.0">
    <channel>
      <title>Bamboo build results feed for the #{params[0][:name]} build</title>
      <link>http://fakeproj.org/bamboo</link>
      <description>This feed is updated whenever the #{params[0][:name]} build gets built</description>
    )
    params.each do |item_params|
      result += create_feed_item_xml(item_params)
    end
    result << %Q(
    </channel>
    </rss>    
    )
  end
  
  def create_feed_item_xml(params = {})
    default_params = {
      :last_build_status => :success,
      :last_build_label => '39',
      :last_build_time => 'Sun, 17 Jan 2010 17:39:35 GMT',
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    }
    values = default_params.merge(params)
    
    <<-RSS
      <item>
        <title>#{values[:last_build_label]} #{values[:last_build_status] == :success ? 'was SUCCESSFUL: ' : 'has FAILED : '}&lt;a href="#{values[:web_url]}/commit"&gt;Updated by Aman King&lt;/a&gt;</title>
        <link>#{values[:web_url]}</link>
        <description>some commit description</description>
        <pubDate>#{values[:last_build_time]}</pubDate>
        <guid>#{values[:web_url]}</guid>
        <dc:date>#{DateTime.parse(values[:last_build_time]).strftime('%Y-%m-%dT%H:%M:%SZ')}</dc:date>
      </item>
    RSS
  end
end