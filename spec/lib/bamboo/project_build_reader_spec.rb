require File.join(File.dirname(__FILE__), '../../spec_helper')
require 'lib/bamboo/project_build_reader'

describe 'project build reader' do
  include ObjectFactory
  
  before(:each) do
    YAML.should_receive(:load_file).with('config file path').and_return([{
      'a_bamboo_server' => { 'url' => 'http://somedomain.com/bamboo/', 'build_keys' => [ 'FAKEPROJ-MYPROJ1', 'FAKEPROJ-MYPROJ2' ] }
    }])
    
    @rss_uri1 = URI.parse('http://somedomain.com/bamboo/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=FAKEPROJ-MYPROJ1')
    @rss_uri2 = URI.parse('http://somedomain.com/bamboo/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=FAKEPROJ-MYPROJ2')
    
    @project_build_reader = Bamboo::ProjectBuildReader.new('config file path')
  end
  
  it 'should read config and parse feeds to return project builds' do    
    Net::HTTP.should_receive(:get).with(@rss_uri1).and_return(create_feed_xml(
      :last_build_label => 'FAKEPROJ-MYPROJ1-39',
      :last_build_time => 'Sun, 17 Jan 2010 17:39:35 GMT',
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ1-39'
    ))
    Net::HTTP.should_receive(:get).with(@rss_uri2).and_return(create_feed_xml(
      :last_build_label => 'FAKEPROJ-MYPROJ2-20',
      :last_build_time => 'Sun, 16 Jan 2010 10:00:00 GMT',
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-20'
    ))
    
    @project_build_reader.project_builds.should == [ 
      create_project_build(
        :name => 'FAKEPROJ-MYPROJ1',
        :last_build_label => 'FAKEPROJ-MYPROJ1-39',
        :last_build_time => DateTime.parse('Sun, 17 Jan 2010 17:39:35 GMT'),
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ1-39'      
      ),
      create_project_build(
        :name => 'FAKEPROJ-MYPROJ2',
        :last_build_label => 'FAKEPROJ-MYPROJ2-20',
        :last_build_time => DateTime.parse('Sun, 16 Jan 2010 10:00:00 GMT'),
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-20'
      )
    ]
  end
  
  it 'should skip a project build if a standard error occurs' do
    Net::HTTP.should_receive(:get).with(@rss_uri1).and_raise('http error')
    Net::HTTP.should_receive(:get).with(@rss_uri2).and_return(create_feed_xml(
      :last_build_label => 'FAKEPROJ-MYPROJ2-20',
      :last_build_time => 'Sun, 16 Jan 2010 10:00:00 GMT',
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-20'
    ))
    
    @project_build_reader.project_builds.should == [ 
      create_project_build(
        :name => 'FAKEPROJ-MYPROJ2',
        :last_build_label => 'FAKEPROJ-MYPROJ2-20',
        :last_build_time => DateTime.parse('Sun, 16 Jan 2010 10:00:00 GMT'),
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-20'
      )
    ]
  end

  it 'should retry once if a timeout error occurs' do
    Net::HTTP.should_receive(:get).with(@rss_uri1).ordered.and_raise(Timeout::Error.new('timeout error'))
    Net::HTTP.should_receive(:get).with(@rss_uri1).ordered.and_return(create_feed_xml(
      :last_build_label => 'FAKEPROJ-MYPROJ1-39',
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ1-39'      
    ))

    Net::HTTP.should_receive(:get).with(@rss_uri2).and_return(create_feed_xml(
      :last_build_label => 'FAKEPROJ-MYPROJ2-20',
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-20'
    ))

    @project_build_reader.project_builds.should == [ 
      create_project_build(
        :name => 'FAKEPROJ-MYPROJ1',
        :last_build_label => 'FAKEPROJ-MYPROJ1-39',
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ1-39'      
      ),
      create_project_build(
        :name => 'FAKEPROJ-MYPROJ2',
        :last_build_label => 'FAKEPROJ-MYPROJ2-20',
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-20'
      )
    ]
  end

  it 'should skip a project build if a timeout error occurs twice' do
    Net::HTTP.should_receive(:get).with(@rss_uri1).ordered.and_raise(Timeout::Error.new('timeout error'))
    Net::HTTP.should_receive(:get).with(@rss_uri1).ordered.and_raise(Timeout::Error.new('timeout error'))

    Net::HTTP.should_receive(:get).with(@rss_uri2).and_return(create_feed_xml(
      :last_build_label => 'FAKEPROJ-MYPROJ2-20',
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-20'
    ))

    @project_build_reader.project_builds.should == [ 
      create_project_build(
        :name => 'FAKEPROJ-MYPROJ2',
        :last_build_label => 'FAKEPROJ-MYPROJ2-20',
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-20'
      )
    ]
  end
end
