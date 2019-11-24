require File.join(File.dirname(__FILE__), '../spec_helper')
require 'app/bamboo_to_cctray'

describe 'Bamboo To CC Tray', :skip => true do
  include ObjectFactory
  
  it 'should convert Bamboo feed to CC Tray format xml' do
    expect(YAML).to receive(:load_file).with(/config\/bamboo.yml/).and_return([{
      'a_bamboo_server' => { 'url' => 'http://somedomain.com/bamboo/', 'build_keys' => [ 'FAKEPROJ-MYPROJ' ] }
    }])
    
    feed_uri = URI.parse('http://somedomain.com/bamboo/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=FAKEPROJ-MYPROJ')
    feed_xml = create_bamboo_rest_result(
      :name => 'FAKEPROJ-MYPROJ',
      :last_build_status => :success,
      :last_build_label => '39',
      :last_build_time => 'Sun, 17 Jan 2010 17:39:35 GMT',
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    )
    expect(Net::HTTP).to receive(:get).with(feed_uri).and_return(feed_xml)

    report_xml = BambooToCcTray.new.to_cctray
    
    expect(report_xml).to have_project_tag_count(1)
    expect(report_xml).to have_project_tags(
      'lastBuildLabel' => '39',
      'lastBuildTime' => '2010-01-17T17:39:35Z',
      'name' => 'FAKEPROJ-MYPROJ',
      'webUrl' => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39',
      'activity' => 'Sleeping',
      'lastBuildStatus' => 'Success'
    )
  end
  
end
