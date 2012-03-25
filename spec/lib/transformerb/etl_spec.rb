require 'spec_helper'

describe Transformerb::Etl do
  describe '#fields' do
    before do
      class DummyExtractor; end
      class DummyLoader; end

      @etl = Transformerb::Etl.new

      @etl.extractor = DummyExtractor.new
      data = { 'name' => 'Lionel', 'Last name' => 'Messi' }
      @etl.extractor.stub!(:next).and_return(data, nil)

      @etl.loader = DummyLoader.new
      @etl.loader.stub!(:write).and_return nil

      @setup =<<-EOF
        fields do
          take 'name'
          take 'Last name'
        end
        EOF
    end

    it 'sets the import_attributes correctly' do
      @etl.run(@setup)

      @etl.import_attributes[:name].should == 'Lionel'
      @etl.import_attributes[:last_name].should == 'Messi'
    end
  end

  describe '#source' do
    before do
      @setup =<<-EOF
        source CSV do
          file 'spec/lib/transformerb/adapters/spec.csv'
          parser_config do |config|
            config.headers = :first_row
          end
        end

        fields do
          take 'name'
          take 'Last name'
        end
      EOF

      @etl = Transformerb::Etl.new

      @etl.loader = DummyLoader.new
      @etl.loader.stub!(:write).and_return nil
    end

    it 'uses the source (extract) correctly' do
      @etl.run(@setup)

      @etl.extractor.should be_a(Transformerb::Adapters::Csv::Extractor)
    end

  end

  describe '#load' do
    before do
      @setup =<<-EOF
        fields do
          take 'name'
          take 'Last name'
        end

        load CSV do
          file '/tmp/output_spec.csv'
        end
      EOF

      @etl = Transformerb::Etl.new

      @etl.extractor = DummyExtractor.new
      data = { 'name' => 'Lionel', 'Last name' => 'Messi' }
      @etl.extractor.stub!(:next).and_return(data, nil)
    end

    it 'sets up the correct output (load)' do
      @etl.run(@setup)

      @etl.loader.should be_a(Transformerb::Adapters::Csv::Loader)
    end

  end

  describe '#run' do
    before do
      @setup =<<-EOF
        source CSV do
          file 'spec/lib/transformerb/adapters/spec.csv'
          parser_config do |config|
            config.headers = :first_row
          end
        end

        fields do
          take 'first name'
          take 'last'
        end

        load CSV do
          file 'spec/lib/transformerb/adapters/output_spec.csv'
        end
      EOF

      @file_path = 'spec/lib/transformerb/adapters/output_spec.csv'

      @etl = Transformerb::Etl.new
    end

    it 'writes the result of the transformation' do
      @etl.run(@setup)

      csv_file_content = File.open(@file_path).read
      csv_file_content.should == "Andres,Iniesta\nVictor,Valdes\n"
    end

    after do
      FileUtils.remove_file(@file_path) if File.exists?(@file_path)
    end
  end

end
