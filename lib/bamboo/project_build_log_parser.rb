require 'nokogiri'
require 'model/project_build_log'
require 'model/project_build'

module Bamboo
  class ProjectBuildLogParser
    def parse(rss_feed)
      doc = Nokogiri::XML::Document.parse(rss_feed)
      doc.xpath('rss/channel/item').inject(ProjectBuildLog.new) do |project_build_log, item_node|
        project_build_log << project_build_from(item_node)
        project_build_log
      end
    end
    
    private
    def project_build_from(item_node)
      project_build_params = ProjectBuildItemNode.new(item_node).to_hash
      ProjectBuild.new(project_build_params)      
    end
    
    class ProjectBuildItemNode
      def initialize(item_node)
        @item_node = item_node
      end

      def web_url
        @item_node.xpath('link').text
      end

      def last_build_label
        web_url.match(/\/browse\/(.*?)-([0-9]+)\/?$/)[2]
      end

      def name
        @item_node.parent.xpath('title').text.slice(/for the (.*) build/, 1)
      end

      def last_build_time
        DateTime.parse(@item_node.xpath('pubDate').text)
      end

      def last_build_status
        @item_node.xpath('title').text =~ /#{last_build_label} was SUCCESSFUL/ ? :success : :failure
      end

      def to_hash
        {
          :name => name,
          :activity => :sleeping,
          :last_build_status => last_build_status,
          :last_build_label => last_build_label,
          :last_build_time => last_build_time,
          :next_build_time => nil,
          :web_url => web_url
        }
      end
    end
  end
end