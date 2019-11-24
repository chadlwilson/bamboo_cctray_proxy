require 'model/project_build_log'
require 'model/project_build'

module Bamboo
  class ProjectBuildLogParser

    def parse(result)
      ProjectBuild.new(ProjectBuildResult.new(result).to_hash)
    end

    private

    class ProjectBuildResult
      def initialize(result)
        @result = result
      end

      def web_url
        @result.url
      end

      def last_build_label
        @result.number
      end

      def name
        @result.plan_name
      end

      def activity
        case @result.life_cycle_state
        when :finished then
          :sleeping
        when :not_built then
          :sleeping
        else
          :building
        end
      end

      def last_build_time
        @result.completed_time || @result.started_time
      end

      def last_build_status
        case @result.state
        when :successful then
          :success
        when :failed then
          :failure
        when :unknown then
          :building
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