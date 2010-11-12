$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'ramaze'))

require 'app'

Ramaze.start(:file => __FILE__, :started => true)
run Ramaze