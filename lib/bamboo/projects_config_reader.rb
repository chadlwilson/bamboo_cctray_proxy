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
      build_keys = server_config.build_keys
      if build_keys.nil?
        build_keys = build_keys_for(server_config)
      end
      build_keys.map { |build_key| project_build_log_cxn_for(server_config.connection, build_key) }
    end

    private
    def build_keys_for(server_config)
      connection = server_config.connection
      project_keys = server_config.projects

      client = Bamboo::Client.for(:rest, connection[:url])
      if connection[:basic_auth]
        client.login(connection[:basic_auth]['username'], connection[:basic_auth]['password'])
      end
      projects = project_keys.nil? ? client.projects : project_keys.map { |projectKey| client.project_for(projectKey) }

      projects.collect { |project|
        project.plans
            .select { |plan| plan.enabled? }
            .map { |plan| plan.key }
      }.flatten
    end

    def project_build_log_cxn_for(server_connection, build_key)
      {
          url: server_connection[:url] + slash_after(server_connection[:url]) + 'rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=' + build_key,
          basic_auth: server_connection[:basic_auth]
      }
    end

    def slash_after(url)
      url =~ /\/$/ ? '' : '/'
    end

    ServerConfig = Struct.new(:name, :connection, :projects, :build_keys)
  end
end