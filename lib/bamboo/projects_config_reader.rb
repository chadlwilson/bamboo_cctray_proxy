require 'yaml'

module Bamboo
  class ProjectsConfigReader
    def initialize(config_file_path)
      @config_file_path = config_file_path
    end

    def project_build_log_cxns
      config.inject([]) do |result, server_config|
        result << project_build_log_cxns_for(server_config.connection, server_config.build_keys)
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
            server_detail.values.first['build_keys'])
      end
    end

    def project_build_log_cxns_for(server_connection, build_keys)
      build_keys.inject([]) do |result, build_key|
        result << project_build_log_cxn_for(server_connection, build_key)
        result
      end
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

    ServerConfig = Struct.new(:name, :connection, :build_keys)
  end
end