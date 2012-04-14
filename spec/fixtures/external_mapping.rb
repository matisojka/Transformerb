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
