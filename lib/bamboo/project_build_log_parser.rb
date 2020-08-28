require './model/project_build_log'
require './model/project_build'

module Bamboo
  class ProjectBuildLogParser

    def parse(plan, result)
      ProjectBuild.new(ProjectBuildResult.new(plan, result).to_hash)
    end

    private

    class ProjectBuildResult
      def initialize(plan, result)
        @plan = plan
        @result = result
      end

      def web_url
        @result.url
      end

      def last_build_label
        @result.number
      end

      def name
        @plan.short_name
      end

      def activity
        @plan.active? ? :building : :sleeping
      end

      def last_build_time
        @result.completed_time
      end

      def last_build_status
        case @result.state
        when :successful then
          :success
        when :failed then
          :failure
        else
          :unknown
        end
      end

      def to_hash
        {
            :name => name,
            :activity => activity,
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