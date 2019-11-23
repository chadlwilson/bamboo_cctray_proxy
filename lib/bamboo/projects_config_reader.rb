require 'yaml'

module Bamboo
  class ProjectsConfigReader
    def initialize(config_file_path)
      @config_file_path = config_file_path
    end
    
    def project_build_log_urls
      config.inject([]) do |result, server_config|
        result << project_build_log_urls_for(server_config.url, server_config.build_keys)
        result
      end.flatten
    end
    
    private
    def config
      @config ||= server_configs
    end
    
    def server_configs
      YAML.load_file(@config_file_path).collect do |server_detail|
        ServerConfig.new(server_detail.keys.first, server_detail.values.first['url'], server_detail.values.first['build_keys'])
      end
    end
    
    def project_build_log_urls_for(server_url, build_keys)
      build_keys.inject([]) do |result, build_key|
        result << project_build_log_url_for(server_url, build_key)
        result
      end
    end
    
    def project_build_log_url_for(server_url, build_key)
      server_url + slash_after(server_url) + 'rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=' + build_key
    end
    
    def slash_after(url)
      url =~ /\/$/ ? '' : '/' 
    end
    
    ServerConfig = Struct.new(:name, :url, :build_keys)
  end
end