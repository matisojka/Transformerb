require 'spec_helper'

describe Transformerb::Etl do

  describe '#transform' do
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
end
