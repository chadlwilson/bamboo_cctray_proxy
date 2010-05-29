require 'rake'
require 'spec/rake/spectask'

desc 'Run specs'
Spec::Rake::SpecTask.new(:rspec) do |t|
  t.spec_opts = ['--options', 'spec/spec.opts']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :default  => :rspec

