require 'spec_helper'

describe Transformerb::Adapters::Csv do
  before do
    @adapter = Transformerb::Adapters::Csv.new
  end

  describe '#file(:file_path)' do
    it 'opens the given file and creates a CSV object' do
      @adapter.extractor.file 'spec/lib/transformerb/adapters/spec.csv'

      @adapter.extractor.source_file.should be_a(IO)
    end
  end

  describe '#parser_config(&block)' do
    it 'passes configuraton params to the parser' do
      @adapter.extractor.parser_config do |config|
        config.col_sep = ','
        config.headers = :first_row
      end

      @adapter.extractor.config.should == { :col_sep => ',', :headers => :first_row }
    end
  end

  describe '#next' do
    before do
      @adapter.extractor.file 'spec/lib/transformerb/adapters/spec.csv'
    end

    it 'returns a key / value hash given headers => :first_row' do
      @adapter.extractor.parser_config do |config|
        config.headers = :first_row
      end

      @adapter.next.should == { 'first name' => 'Andres', 'last' => 'Iniesta', 'age' => '27' }
    end

    it 'returns a hash with index as keys if no attributes are given' do
      @adapter.next.should == { 0 => 'first name', 1 => 'last', 2 => 'age' }
    end
  end

  describe '#write' do
    before do
      @adapter.loader.file 'spec/lib/transformerb/adapters/output_spec.csv'
    end

    it 'writes the content to a file' do
      @adapter.write(0 => 'first', 1 => 'last', 2 => 'age')
      @written_content = File.open(@adapter.loader.destination_file_path, 'r').read
      @written_content.should == "first,last,age\n"
    end

    after do
      system("rm #{@adapter.loader.destination_file_path}")
    end

  end

end
