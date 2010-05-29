require 'net/http'
require 'lib/bamboo/projects_config_reader'
require 'lib/bamboo/project_build_log_parser'

module Bamboo
  class ProjectBuildReader
    def initialize(config_file_path)
      @projects_config_reader = Bamboo::ProjectsConfigReader.new(config_file_path)
      @project_build_log_parser = Bamboo::ProjectBuildLogParser.new      
    end
    
    def project_builds
      project_build_log_urls.collect do |project_build_log_url|
        project_build_log = project_build_log_from(project_build_log_url) rescue next
        project_build_log.latest
      end.compact
    end
    
    private
    def project_build_log_urls
      @projects_config_reader.project_build_log_urls
    end

    def project_build_log_from(project_build_log_url)
      xml = xml_at(project_build_log_url) 
      @project_build_log_parser.parse(xml)
    end

    def xml_at(project_build_log_url)
      Net::HTTP.get(URI.parse(project_build_log_url))
    end    
  end
end