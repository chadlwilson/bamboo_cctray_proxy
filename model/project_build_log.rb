require 'forwardable'

class ProjectBuildLog
  extend Forwardable
  def_delegator :@project_builds, :<<
  def_delegator :@project_builds, :each
  
  include Enumerable
  
  def initialize
    @project_builds = []
  end

  alias_method :latest, :min
end
