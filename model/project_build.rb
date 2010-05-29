require 'attribute_driven'

class ProjectBuild
  include AttributeDriven
  attributes :name, :activity, :last_build_status, :last_build_label, :last_build_time, :next_build_time, :web_url
  
  def <=> (other)
    other.instance_variable_get('@last_build_time') <=> @last_build_time
  end

end
