require 'rubygems'
require 'active_support/inflector'

require 'pry'

if RUBY_VERSION == '1.8.7'
  require 'fastercsv'
  CSV = FasterCSV
else
  require 'csv'
end

require File.join(File.dirname(__FILE__), 'transformerb/etl.rb')
require File.join(File.dirname(__FILE__), 'transformerb/transformer.rb')
require File.join(File.dirname(__FILE__), 'transformerb/entity.rb')
require File.join(File.dirname(__FILE__), 'transformerb/adapters/memory_adapter.rb')
require File.join(File.dirname(__FILE__), 'transformerb/adapters/csv_adapter.rb')
