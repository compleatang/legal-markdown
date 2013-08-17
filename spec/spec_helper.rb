require 'json'
require 'securerandom'
require 'coveralls'
require 'fileutils'
Coveralls.wear!

require 'legal_markdown'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.after(:all) do
    FileUtils.rm(Dir['/tmp/lmdtests*'])
  end
end