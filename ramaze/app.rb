require 'ramaze'

Ramaze.setup :verbose => true do
  gem 'nokogiri', '>= 1.4.0'
  gem 'attribute-driven'
  gem 'retry-this'
end

require File.join(File.dirname(__FILE__), '../init')
require 'controller/dashboard'