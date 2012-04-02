require File.join(File.dirname(__FILE__), 'transformerb/etl.rb')
require File.join(File.dirname(__FILE__), 'transformerb/field_transformer.rb')
require File.join(File.dirname(__FILE__), 'transformerb/adapters/csv_adapter.rb')

require 'rubygems'
require 'active_support/inflector'

require 'date'
require 'pry'

# TODO: Use FasterCSV under Ruby 1.8.7
require 'csv'
