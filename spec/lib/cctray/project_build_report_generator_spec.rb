require File.join(File.dirname(__FILE__), '../../spec_helper')
require 'lib/cctray/project_build_report_generator'

module CcTray
  describe 'project build report generator for CC Tray' do
    include ObjectFactory
    
    it 'should generate report for a single successful project build' do
      project_build = create_project_build(
        :name => 'FAKEPROJ-MYPROJ',
        :activity => :sleeping,
        :last_build_status => :success,
        :last_build_label => '39',
        :last_build_time => Time.parse('2010-01-17T17:39:35Z'),
        :next_build_time => nil,
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
      )

      report_xml = ProjectBuildReportGenerator.new.generate(project_build)
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

    it 'should generate report for a single failed project build' do
      project_build = create_project_build(:last_build_status => :failure)
      report_xml = ProjectBuildReportGenerator.new.generate(project_build)
      expect(report_xml).to have_project_tags('lastBuildStatus' => 'Failure')
    end

    it 'should generate report for multiple project builds' do
      project_build1 = create_project_build(:name => 'FAKEPROJ-MYPROJ1')
      project_build2 = create_project_build(:name => 'FAKEPROJ-MYPROJ2')

      report_xml = ProjectBuildReportGenerator.new.generate(project_build1, project_build2)
      expect(report_xml).to have_project_tag_count(2)
      expect(report_xml).to have_project_tags(
        { 'name' => 'FAKEPROJ-MYPROJ1' },
        { 'name' => 'FAKEPROJ-MYPROJ2' }
      )
    end
  end
end

