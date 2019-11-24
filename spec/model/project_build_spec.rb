require File.join(File.dirname(__FILE__), '../spec_helper')
require 'model/project_build'

describe 'project build' do
  it 'should be equal to itself' do
    project_build = ProjectBuild.new(
      :name => 'FAKEPROJ-MYPROJ',
      :activity => :sleeping,
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ-39',
      :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    )
    expect(project_build).to eq project_build
    expect(project_build.hash).to eq project_build.hash
  end

  it 'should be equal to another project build with same attributes' do
    project_build1 = ProjectBuild.new(
      :name => 'FAKEPROJ-MYPROJ',
      :activity => :sleeping,
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ-39',
      :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    )
    
    project_build2 = ProjectBuild.new(
      :name => 'FAKEPROJ-MYPROJ',
      :activity => :sleeping,
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ-39',
      :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    )
    
    expect(project_build1).to eq project_build2
    expect(project_build1.hash).to eq project_build2.hash
  end

  it 'should not be equal to another project build with different attributes' do
    project_build1 = ProjectBuild.new(
      :name => 'FAKEPROJ-MYPROJ1',
      :activity => :sleeping,
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ1-39',
      :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ1-39'
    )
    
    project_build2 = ProjectBuild.new(
      :name => 'FAKEPROJ-MYPROJ2',
      :activity => :sleeping,
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ2-40',
      :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ2-40'
    )
    
    expect(project_build1).to_not eq project_build2
  end
  
  it 'should sort by last build time descending' do
    project_build1 = ProjectBuild.new(
      :name => 'FAKEPROJ-MYPROJ',
      :activity => :sleeping,
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ-39',
      :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    )
    project_build2 = ProjectBuild.new(
      :name => 'FAKEPROJ-MYPROJ',
      :activity => :sleeping,
      :last_build_status => :success,
      :last_build_label => 'FAKEPROJ-MYPROJ-40',
      :last_build_time => DateTime.parse('2010-01-17T18:39:35Z'),
      :next_build_time => nil,
      :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-40'
    )
    
    expect([ project_build1, project_build2 ].sort).to eq [ project_build2, project_build1 ]
  end
end