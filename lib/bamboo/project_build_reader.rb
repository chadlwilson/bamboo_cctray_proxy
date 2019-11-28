require 'net/http'
require 'retry_this'
require 'concurrent'
require 'lib/bamboo/projects_config_reader'
require 'lib/bamboo/project_build_log_parser'

RestClient.log = STDOUT

module Bamboo
  class ProjectBuildReader
    def initialize(config_file_path)
      @projects_config_reader = Bamboo::ProjectsConfigReader.new(config_file_path)
      @project_build_log_parser = Bamboo::ProjectBuildLogParser.new
      @request_executor = Concurrent::FixedThreadPool.new(20)
    end

    def project_builds
      futures = project_build_log_cxns.collect do |project_build_log_cxn|
        Concurrent::Promises.future(project_build_log_cxn) do |cxn|
          latest_project_build_from(cxn)
        end
      end.compact
      Concurrent::Promises.zip_futures_on(@request_executor, *futures).value!
    end

    private
    def project_build_log_cxns
      @projects_config_reader.project_build_log_cxns
    end

    def latest_project_build_from(project_build_log_cxn)
      retry_this(:times => 1, :error_types => Timeout::Error) do
        project_build_log_from(project_build_log_cxn)
      end
    rescue StandardError, Timeout::Error => e
      puts e.message
      puts e.backtrace
    end

    def project_build_log_from(project_build_log_cxn)
      plan = project_build_log_cxn[:client].plan_for(project_build_log_cxn[:build_key])
      latest_result = project_build_log_cxn[:client].latest_result_for(project_build_log_cxn[:build_key])
      @project_build_log_parser.parse(plan, latest_result)
    end

    include RetryThis
  end
end

# Apply some monkey-patches to the Bamboo Client Rest API to allow us to efficiently invoke it
module BambooClientRestExtensions
  module ClientExtension
    def latest_result_for(planKey)
      result = Bamboo::Client::Rest::Result.new get("result/#{URI.escape planKey}/latest").data, @http
      result.details_from_data
      result
    end
  end

  module PlanExtension
    def active?
      @data['isActive']
    end

    def short_name
      @data.fetch('shortName')
    end
  end

  module ResultExtension
    def details_from_data
      @details = @data
    end
  end
end

Bamboo::Client::Rest::Result.include BambooClientRestExtensions::ResultExtension
Bamboo::Client::Rest::Plan.include BambooClientRestExtensions::PlanExtension
Bamboo::Client::Rest.include BambooClientRestExtensions::ClientExtension
