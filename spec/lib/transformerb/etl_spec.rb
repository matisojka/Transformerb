require 'spec_helper'

describe Transformerb::Etl do
  describe '.new(:data, :setup)' do
    before do
      @data = {
        'name'              => 'Lionel',
        'Last name'         => 'Messi',
        'Fifas best'        => '3',
        'top_score'         => 5,
        'gender'            => 'Man',
        'job'               => 'football player',
        'locality'          => 'Longer than allowed',
        'region'            => nil
      }

      setup =<<-EOF
        fields do
          take 'name'
          take 'Last name'
        end
        EOF

      @etl = Transformerb::Etl.new(@data, setup)
    end

    describe '#fields' do
      it 'sets the import_attributes correctly' do
        @etl.import_attributes[:name].should == 'Lionel'
        @etl.import_attributes[:last_name].should == 'Messi'
      end
    end

    describe '#source' do
      before do
        setup =<<-EOF
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

        @etl = Transformerb::Etl.new(@data, setup)
      end

      it 'uses the source correctly' do
        @etl.extractor.should be_a(Transformerb::Adapters::Csv)
      end

    end

  end
end
