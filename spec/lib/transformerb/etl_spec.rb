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
        pending 'TODO => stub extractor and loader'

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

      it 'uses the source (extract) correctly' do
        @etl.extractor.should be_a(Transformerb::Adapters::Csv::Extractor)
      end

    end

    describe '#load' do
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

          load CSV do
            file 'spec/lib/transformerb/adapters/output_spec.csv'
          end
        EOF

        @etl = Transformerb::Etl.new(@data, setup)
      end

      it 'sets up the correct output (load)' do
        @etl.loader.should be_a(Transformerb::Adapters::Csv::Loader)
      end

    end

    describe '#run' do
      before do
        setup =<<-EOF
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

        @etl = Transformerb::Etl.new(@data, setup)
      end

      it 'writes the result of the transformation' do
        @etl.run
      end
    end

  end
end
