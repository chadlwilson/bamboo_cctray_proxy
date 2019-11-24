require 'yaml'
require 'bamboo-client'

module Bamboo
  class ProjectsConfigReader
    def initialize(config_file_path)
      @config_file_path = config_file_path
    end

    def project_build_log_cxns
      config.inject([]) do |result, server_config|
        result << project_build_log_cxns_for(server_config)
        result
      end.flatten
    end

    private

    def config
      @config ||= server_configs
    end

    def server_configs
      YAML.load_file(@config_file_path).collect do |server_detail|
        ServerConfig.new(
            server_detail.keys.first,
            {
                url: server_detail.values.first['url'],
                basic_auth: server_detail.values.first['basic_auth']
            },
            server_detail.values.first['projects'],
            server_detail.values.first['build_keys'])
      end
    end

    def project_build_log_cxns_for(server_config)
      client = client_for(server_config)
      build_keys = server_config.build_keys
      if build_keys.nil?
        build_keys = build_keys_for(client, server_config.projects)
      end
      build_keys.map { |build_key| { client: client, build_key: build_key }}
    end

    def client_for(server_config)
      client = Bamboo::Client.for(:rest, server_config[:connection][:url])
      if server_config[:connection][:basic_auth]
        client.login(server_config[:connection][:basic_auth]['username'],
                     server_config[:connection][:basic_auth]['password'])
      end
      client
    end

    private
    def build_keys_for(client, project_keys)
      projects = project_keys.nil? ? client.projects : project_keys.map { |projectKey| client.project_for(projectKey) }

      projects.collect { |project|
        project.plans
            .select { |plan| plan.enabled? }
            .map { |plan| plan.key }
      }.flatten
    end

    ServerConfig = Struct.new(:name, :connection, :projects, :build_keys)
  end
end