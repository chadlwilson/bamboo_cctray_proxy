$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'app'

module AppOptions
  def port
    arg_value('port') || 7000
  end

  def adapter
    arg_value = arg_value('adapter')
    arg_value ? arg_value.to_sym : :mongrel
  end

  private
  def arg_value(arg_name)
    arg = ARGV.find { |arg| arg =~ /^(--#{arg_name}=)(.*)$/ }
    arg ? $2 : nil
  end
  
  module_function :port, :adapter, :arg_value
end

if $0 == __FILE__
  Ramaze::Log.info "using adapter #{AppOptions.adapter} (to use another, pass --adapter=<adapter> argument)"
  Ramaze::Log.info "using port #{AppOptions.port} (to use another, pass --port=<port> argument)"

  Ramaze.start :adapter => AppOptions.adapter, :port => AppOptions.port, :mode => :live # run from here only if start.rb invoked directly
end

