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

      setup =<<EOF
fields do
  take 'name'
  take 'Last name'
end
EOF

      @etl = Transformerb::Etl.new(@data, setup)
    end

    it 'sets the import_attributes correctly' do
      @etl.import_attributes[:name].should == 'Lionel'
      @etl.import_attributes[:last_name].should == 'Messi'
    end
  end
end
