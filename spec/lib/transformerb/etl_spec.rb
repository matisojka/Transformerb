require 'spec_helper'

describe Transformerb::Etl do

  describe '#transform from csv to memory' do
    before do
      @transformation = Transformerb::Etl.transform do
        extract :csv, 'spec/fixtures/test_csv.csv' do
          config :headers => :first_row
        end

        transform do
          define :id
          define :last_name => 'Last Name'
          define :first_name, :from => 'First Name' do
            convert do |value|
              value.capitalize
            end
          end
        end

      end
    end

    it 'returns an array of entities' do
      @transformation.should be_a(Array)
      @transformation.first.should be_a(Transformerb::Entity)
      @transformation.size.should == 3
    end

    it 'returns a correct Entity' do
      entity = @transformation.first
      entity.id.should == '1'
      entity.first_name.should == 'Lionel'
      entity.last_name.should == 'Messi'
    end
  end

  describe '#transform from csv to csv' do
    before do
      @transformation = Transformerb::Etl.transform do
        extract :csv, 'spec/fixtures/test_csv.csv'

        transform do
          define :id
          define :last_name => 'Last Name'
          define :first_name, :from => 'First Name' do
            convert do |value|
              value.capitalize
            end
          end

        end

        loader :csv, 'spec/fixtures/output_test_csv.csv'
      end
    end

    it 'creates a CSV file' do
      File.exist?('spec/fixtures/output_test_csv.csv').should be_true
    end

    it 'saves correct content' do
      csv = [].tap do |array|
        CSV.foreach('spec/fixtures/output_test_csv.csv', :headers => :first_row) do |row|
          array << row.to_hash
        end
      end

      csv.length.should               == 3

      csv.first['id'].should          == '1'
      csv.first['first_name'].should  == 'Lionel'
      csv.first['last_name'].should   == 'Messi'
    end

    after do
      FileUtils.rm('spec/fixtures/output_test_csv.csv')
    end
  end

  describe 'external mapping file' do
    before do
      @transformation = Transformerb::Etl.transform('spec/fixtures/external_mapping.rb')
    end

    it 'returns an array of entities' do
      @transformation.should be_a(Array)
      @transformation.first.should be_a(Transformerb::Entity)
      @transformation.size.should == 3
    end

    it 'returns a correct Entity' do
      entity = @transformation.first
      entity.id.should == '1'
      entity.first_name.should == 'Lionel'
      entity.last_name.should == 'Messi'
    end
  end

  describe 'field validation' do
    before do
      @transformation = Transformerb::Etl.transform do
        extract :csv, 'spec/fixtures/test_csv_missing_id.csv'

        transform do
          define :id do
            validates :presence => true
          end

        end
      end

    end

    it 'marks entities with missing id as not valid' do
      @transformation.select { |entity| entity.valid? }.size.should == 1
    end

  end

end
