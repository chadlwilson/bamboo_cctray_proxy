require File.join(File.dirname(__FILE__), '../spec_helper')
require 'model/project_build_log'

describe 'project build log' do
  include ObjectFactory
  
  before(:each) do
    @project_build1 = create_project_build(
      :name => 'FAKEPROJ-MYPROJ',
      :activity => :checking_modifications, 
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ-39',
      :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    )
    
    @project_build2 = create_project_build(
      :name => 'FAKEPROJ-MYPROJ', 
      :activity => :checking_modifications, 
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ-40',
      :last_build_time => DateTime.parse('2010-01-17T18:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-40'
    )
    
    @project_build_log = ProjectBuildLog.new
    @project_build_log << @project_build1
    @project_build_log << @project_build2
  end
  
  it 'should return added project builds' do
    @project_build_log.entries.should == [ @project_build1, @project_build2 ]
  end
  
  it 'should find latest according to last build time' do
    @project_build_log.latest.should == @project_build2
  end
end
