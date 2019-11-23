require 'ramaze'

Ramaze.setup do
  gem 'nokogiri', '>= 1.10.4'
  gem 'attribute-driven'
  gem 'retry-this'
end

require File.join(File.dirname(__FILE__), '../init')
require 'controller/dashboard'