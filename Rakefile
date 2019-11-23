require 'rake'
require 'rspec/core/rake_task'

desc 'Run specs'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.rspec_opts = ["-c", "-f progress"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default  => :rspec

