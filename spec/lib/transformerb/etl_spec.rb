require 'spec_helper'

describe Transformerb::Etl do
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

    @etl = Transformerb::Etl.new(@data)
  end

  describe '.new(:data, :setup)' do
    before do

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

  describe '#define(:field_name => :type, max_length)' do

    it 'defines a destination attribute with given params' do
      @etl.fields do
        define :city => :string, :length => 10
      end

      @etl.field_definitions[:city].should == {:type => :string, :length => 10 }
    end

    it 'correctly truncates the value of a defined field' do
      @etl.fields do
        define :city => :string, :length => 10

        take 'locality' => :city
      end

      @etl.import_attributes[:city].should == 'Longer tha'
    end

  end

  describe '#take(:field_name(s), :as => :variable, :join_with => :join_element)' do

    it 'reads the content from a specific column and saves it as a variable' do
      @etl.fields do
        take 'gender', :as => :gender
      end

      @etl.import_attributes[:gender].should == 'Man'
    end

    it 'reads the content from a specific column and saves it as a variable (using defaults)' do
      @etl.fields do
        take 'Last name'
      end

      @etl.import_attributes[:last_name].should == 'Messi'
    end

    it 'reads the content from a specific column and saves it as a variable (using defaults)' do
      @etl.fields do
        take 'job' => :work
      end

      @etl.import_attributes[:work].should == 'football player'
    end

    it 'reads the content and transforms it if block is given' do
      @etl.fields do
        take 'name', :as => :first_name do |name|
          "#{name} Andres"
        end
      end

      @etl.import_attributes[:first_name].should == 'Lionel Andres'
    end

    it 'joins an array of source fields without a joiner if no joiner is present' do
      @etl.fields do
        take ['name', 'Last name'], :as => :full_name
      end

      @etl.import_attributes[:full_name].should == 'LionelMessi'
    end

    it 'joins an array of source fields without a joiner' do
      @etl.fields do
        take ['name', 'Last name'], :as => :full_name, :join_with => ' / '
      end

      @etl.import_attributes[:full_name].should == 'Lionel / Messi'
    end

    describe '#normalize_attribute_name' do
      it 'returns word characters or underscore only' do
        @etl.fields do
          send(:normalize_attribute_name, 'What  a beautiful day!').to_s.should =~ /\w+/
        end
      end

      it 'returns word characters or underscore only' do
        @etl.fields do
          send(:normalize_attribute_name, 'What  a beautiful day!').should == :what_a_beautiful_day
        end
      end

    end
  end

  describe '#take_and_map(:field_name(s), :mapping, :as => :variable, :join_with => :join_element, :default => :default)' do
    before do
      @etl.stub!(:data).and_return({})
    end

    it 'returns "M" when "Herr" is given (regexp)' do
      @etl = Transformerb::Etl.new('anrede' => 'Herr')

      @etl.fields do
        @mapping = { 'M' => /Herr.*/, 'F' => 'Frau', 'T' => ['Trans', 'Tr'] }
        take_and_map 'anrede', @mapping, :as => :gender
      end

      @etl.import_attributes[:gender].should == 'M'
    end

    it 'returns "M" when "Herrn" is given (regexp)' do
      @etl = Transformerb::Etl.new('anrede' => 'Herrn')

      @etl.fields do
        @mapping = { 'M' => /Herr.*/, 'F' => 'Frau', 'T' => ['Trans', 'Tr'] }
        take_and_map 'anrede', @mapping, :as => :gender
      end

      @etl.import_attributes[:gender].should == 'M'
    end

    it 'returns "F" when "Frau" is given (string)' do
      @etl = Transformerb::Etl.new('anrede' => 'Frau')

      @etl.fields do
        @mapping = { 'M' => /Herr.*/, 'F' => 'Frau', 'T' => ['Trans', 'Tr'] }
        take_and_map 'anrede', @mapping, :as => :gender
      end

      @etl.import_attributes[:gender].should == 'F'
    end

    it 'returns "T" when value is Trans and array is given' do
      @etl = Transformerb::Etl.new('anrede' => 'Trans')

      @etl.fields do
        @mapping = { 'M' => /Herr.*/, 'F' => 'Frau', 'T' => ['Trans', 'Tr'] }
        take_and_map 'anrede', @mapping, :as => :gender
      end

      @etl.import_attributes[:gender].should == 'T'
    end

    it 'returns "T" when value is Tr and array is given' do
      @etl = Transformerb::Etl.new('anrede' => 'Tr')

      @etl.fields do
        @mapping = { 'M' => /Herr.*/, 'F' => 'Frau', 'T' => ['Trans', 'Tr'] }
        take_and_map 'anrede', @mapping, :as => :gender
      end

      @etl.import_attributes[:gender].should == 'T'
    end

    it 'returns "N" when there is no match and default is given' do
      @etl = Transformerb::Etl.new('anrede' => 'Unknown')

      @etl.fields do
        @mapping = { 'M' => /Herr.*/, 'F' => 'Frau', 'T' => ['Trans', 'Tr'] }
        take_and_map 'anrede', @mapping, :as => :gender, :default => 'N'
      end

      @etl.import_attributes[:gender].should == 'N'
    end

    it 'returns the default value if mapping is empty' do
      @etl = Transformerb::Etl.new('anrede' => 'Unknown')

      @etl.fields do
        @mapping = { 'M' => /Herr.*/, 'F' => 'Frau', 'T' => ['Trans', 'Tr'] }
        take_and_map 'anrede', {}, :as => :gender, :default => 'N'
      end

      @etl.import_attributes[:gender].should == 'N'
    end

  end

  describe '#cast(:attribute, :to => :type)' do
    it 'allows to cast a field to string' do
      @etl.import_attributes[:first_name] = 5

      @etl.fields do
        cast :first_name, :to => :string
      end

      @etl.import_attributes[:first_name].should be_a(String)
    end

    it 'allows to cast a field to integer' do
      @etl.import_attributes[:fifas_best] = '3'

      @etl.fields do
        cast :fifas_best, :to => :integer
      end

      @etl.import_attributes[:fifas_best].should be_a(Fixnum)
    end

    it 'allows to cast a field to DateTime' do
      @etl.import_attributes[:birthday] = '24-06-1987'

      @etl.fields do
        cast :birthday, :to => :datetime
      end

      @etl.import_attributes[:birthday].should be_a(DateTime)
    end

    it 'casts a field to String if no args are given' do
      @etl.import_attributes[:top_score] = 5

      @etl.fields do
        cast :top_score
      end

      @etl.import_attributes[:top_score].should be_a(String)
    end

    describe '#edit(:attribute)' do
      before do
        @etl.import_attributes[:top_speed] = 20
      end

      it 'allows to freely transform an attribute' do
        @etl.fields do
          edit :top_speed do |speed|
            speed += 1
          end
        end

        @etl.import_attributes[:top_speed].should == 21
      end
    end

  end

end
