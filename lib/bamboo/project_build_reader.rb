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
      project_build_log_cxns.collect do |project_build_log_cxn|
        latest_project_build_from(project_build_log_cxn)
      end.compact
    end

    private
    def project_build_log_cxns
      @projects_config_reader.project_build_log_cxns
    end

    def latest_project_build_from(project_build_log_cxn)
      retry_this(:times => 1, :error_types => Timeout::Error) do
        project_build_log_from(project_build_log_cxn).latest
      end
    rescue StandardError, Timeout::Error
      nil
    end

    def project_build_log_from(project_build_log_cxn)
      xml = xml_at(project_build_log_cxn)
      @project_build_log_parser.parse(xml)
    end

    def xml_at(project_build_log_cxn)
      uri = URI.parse(project_build_log_cxn[:url])
      if project_build_log_cxn[:basic_auth]
        req = Net::HTTP::Get.new(uri)
        req.basic_auth(
            project_build_log_cxn[:basic_auth]["username"],
            project_build_log_cxn[:basic_auth]["password"])
        res = Net::HTTP.start(uri.hostname,
                              uri.port,
                              :use_ssl => project_build_log_cxn[:url].start_with?("https")
        ) { |http|
          http.request(req)
        }
        res.body
      else
        Net::HTTP.get(uri)
      end
    end

    include RetryThis
  end
end