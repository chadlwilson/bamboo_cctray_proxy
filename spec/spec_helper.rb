require 'spec'

require File.join(File.dirname(__FILE__), 'object_factory')

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |path| require path }

require File.join(File.dirname(__FILE__), '../init')