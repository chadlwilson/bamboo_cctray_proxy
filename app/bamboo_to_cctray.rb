require './lib/bamboo/project_build_reader'
require './lib/cctray/project_build_report_generator'

class BambooToCcTray  
  def initialize
    @project_build_reader = Bamboo::ProjectBuildReader.new(config_file_path)
    @project_build_report_generator = CcTray::ProjectBuildReportGenerator.new
  end
  
  def to_cctray
    generate_cctray_xml
  end
  
  private
  def generate_cctray_xml
    project_builds = @project_build_reader.project_builds
    @project_build_report_generator.generate(*project_builds)    
  end
  
  def config_file_path
    File.join(File.dirname(__FILE__), '../tmp/bamboo.yml')
  end
end