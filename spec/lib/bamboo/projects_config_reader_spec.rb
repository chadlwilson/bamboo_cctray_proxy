require File.join(File.dirname(__FILE__), '../../spec_helper')
require 'lib/bamboo/projects_config_reader'

module Bamboo
  describe 'projects config reader' do
    before(:each) do
      @projects_config_reader = ProjectsConfigReader.new('yaml_file_path')
    end
    
    describe 'reading file with single Bamboo server' do
      before(:each) do
        YAML.should_receive(:load_file).with('yaml_file_path').and_return([
          {
            'a_bamboo_server' => { 'url' => 'http://somedomain.com/bamboo/', 'build_keys' => [ 'FAKEPROJ-MYPROJ1', 'FAKEPROJ-MYPROJ2' ] }
          }
        ])
      end
      
      it 'should return Bamboo RSS urls for multiple projects' do
        @projects_config_reader.project_build_log_urls.should == [
          'http://somedomain.com/bamboo/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=FAKEPROJ-MYPROJ1',
          'http://somedomain.com/bamboo/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=FAKEPROJ-MYPROJ2'
        ]
      end
    end
    
    describe 'reading file with multiple Bamboo servers' do
      before(:each) do
        YAML.should_receive(:load_file).with('yaml_file_path').and_return([
          {
            'a_bamboo_server' => { 'url' => 'http://xyz.com/builds/', 'build_keys' => [ 'FAKEPROJ-MYPROJ1' ] }
          },
          { 
            'another_bamboo_server' => { 'url' => 'http://abc.com/bamboo', 'build_keys' => [ 'FAKEPROJ-MYPROJ1', 'FAKEPROJ-MYPROJ2' ] }
          }
        ])
      end
      
      it 'should return Bamboo RSS urls for multiple projects' do
        @projects_config_reader.project_build_log_urls.should == [
          'http://xyz.com/builds/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=FAKEPROJ-MYPROJ1',
          'http://abc.com/bamboo/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=FAKEPROJ-MYPROJ1',
          'http://abc.com/bamboo/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=FAKEPROJ-MYPROJ2'
        ]
      end
    end
  end
end
