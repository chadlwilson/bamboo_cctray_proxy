require 'net/http'
require 'retry_this'
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
        latest_project_build_from(project_build_log_url)
      end.compact
    end
    
    private
    def project_build_log_urls
      @projects_config_reader.project_build_log_urls
    end
    
    def latest_project_build_from(project_build_log_url)
      retry_this(:times => 1, :error_types => Timeout::Error) do
        project_build_log_from(project_build_log_url).latest
      end
    rescue StandardError, Timeout::Error
      nil
    end
    
    def project_build_log_from(project_build_log_url)
      xml = xml_at(project_build_log_url) 
      @project_build_log_parser.parse(xml)
    end

    def xml_at(project_build_log_url)
      Net::HTTP.get(URI.parse(project_build_log_url))
    end
    
    include RetryThis
  end
end