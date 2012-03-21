require 'spec_helper'

describe Transformerb::Adapters::Csv do
  before do
    @adapter = Transformerb::Adapters::Csv.new
  end

  describe '#file(:file_path)' do
    it 'opens the given file and creates a CSV object' do
      @adapter.file 'spec/lib/transformerb/adapters/spec.csv'

      @adapter.file_obj.should be_a(IO)
    end
  end

  describe '#parser_config(&block)' do
    it 'passes configuraton params to the parser' do
      @adapter.parser_config do |config|
        config.col_sep = ','
        config.headers = :first_row
      end

      @adapter.config.should == { :col_sep => ',', :headers => :first_row }
    end
  end

  describe '#next' do
    before do
      @adapter.file 'spec/lib/transformerb/adapters/spec.csv'
    end

    it 'returns a key / value hash given headers => :first_row' do
      @adapter.parser_config do |config|
        config.headers = :first_row
      end

      @adapter.next.should == { 'first name' => 'Andres', 'last' => 'Iniesta', 'age' => '27' }
    end

    it 'returns a hash with index as keys if no attributes are given' do
      @adapter.next.should == { 0 => 'first name', 1 => 'last', 2 => 'age' }
    end
  end

end
