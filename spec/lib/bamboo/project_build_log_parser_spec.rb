require File.join(File.dirname(__FILE__), '../../spec_helper')
require 'lib/bamboo/project_build_log_parser'

module Bamboo
  describe 'project build log parser for Bamboo' do
    include ObjectFactory

    it 'should parse a single rss item to detect success' do
      project_build_log_parser = ProjectBuildLogParser.new
      feed_xml = create_feed_xml(
        :name => 'FAKEPROJ-MYPROJ',
        :last_build_status => :success,
        :last_build_label => '39',
        :last_build_time => 'Sun, 17 Jan 2010 17:39:35 GMT',
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
      )
      project_build_log = project_build_log_parser.parse(feed_xml)
      expect(project_build_log.latest).to eq create_project_build(
        :name => 'FAKEPROJ-MYPROJ',
        :activity => :sleeping,
        :last_build_status => :success,
        :last_build_label => '39',
        :last_build_time => DateTime.parse('Sun, 17 Jan 2010 17:39:35 GMT'),
        :next_build_time => nil,
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
      )
    end

    it 'should parse a single rss item to detect failure' do
      project_build_log_parser = ProjectBuildLogParser.new
      feed_xml = create_feed_xml(
        :name => 'FAKEPROJ-MYPROJ',
        :last_build_status => :failure,
        :last_build_label => '39',
        :last_build_time => 'Sun, 17 Jan 2010 17:39:35 GMT',
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
      )
      project_build_log = project_build_log_parser.parse(feed_xml)
      expect(project_build_log.latest).to eq create_project_build(
        :name => 'FAKEPROJ-MYPROJ', 
        :activity => :sleeping,
        :last_build_status => :failure,
        :last_build_label => '39',
        :last_build_time => DateTime.parse('Sun, 17 Jan 2010 17:39:35 GMT'),
        :next_build_time => nil,
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
      )
    end

    it 'should parse multiple rss items and record project builds for them' do
      project_build_log_parser = ProjectBuildLogParser.new
      feed_xml = create_feed_xml(
        {
          :name => 'FAKEPROJ-MYPROJ',
          :last_build_status => :success,
          :last_build_label => '39',
          :last_build_time => 'Sun, 17 Jan 2010 17:39:35 GMT',
          :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
        },
        {
          :name => 'FAKEPROJ-MYPROJ',
          :last_build_status => :failure,
          :last_build_label => '38',
          :last_build_time => 'Sun, 16 Jan 2010 10:00:00 GMT',
          :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-38'
        }
      )
      project_build_log = project_build_log_parser.parse(feed_xml)
      expect(project_build_log.entries).to eq [
        create_project_build(
          :name => 'FAKEPROJ-MYPROJ',
          :activity => :sleeping,
          :last_build_status => :success,
          :last_build_label => '39',
          :last_build_time => DateTime.parse('Sun, 17 Jan 2010 17:39:35 GMT'),
          :next_build_time => nil,
          :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
        ),
        create_project_build(
          :name => 'FAKEPROJ-MYPROJ',
          :activity => :sleeping,
          :last_build_status => :failure,
          :last_build_label => '38',
          :last_build_time => DateTime.parse('Sun, 16 Jan 2010 10:00:00 GMT'),
          :next_build_time => nil,
          :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-38'
        )
      ]
    end
  end
end