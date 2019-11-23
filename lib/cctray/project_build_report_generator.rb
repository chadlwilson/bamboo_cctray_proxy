require 'nokogiri'

module CcTray
  class ProjectBuildReportGenerator
    def generate(*project_builds)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.Projects {
          project_builds.each do |project_build|
            xml.Project(
              :lastBuildLabel => project_build.last_build_label,
              :lastBuildTime => format_last_build_time(project_build.last_build_time),
              :name => project_build.name,
              :webUrl => project_build.web_url,
              :activity => format_activity(project_build.activity),
              :lastBuildStatus => format_last_build_status(project_build.last_build_status)
            )
          end
        }
      end
      builder.to_xml
    end
    
    private
    def format_last_build_time(last_build_time)
      last_build_time.strftime('%Y-%m-%dT%H:%M:%S.0000000-00:00')
    end
    
    def format_activity(activity)
      case activity
      when :checking_modifications then 'CheckingModifications'
      when :sleeping then 'Sleeping'
      when :building then 'Building'
      end
    end
    
    def format_last_build_status(last_build_status)
      case last_build_status
      when :success then 'Success'
      when :failure then 'Failure'
      end
    end
  end
end