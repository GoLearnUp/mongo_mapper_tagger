require 'rubygems'
require 'bundler/setup'
require 'byebug'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'mongo_mapper_tagger'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "mongo_mapper_tagger_test-#{RUBY_VERSION.gsub('.', '-')}"
MongoMapper.database.collections.each { |c| c.drop_indexes }

def wipe_db
  MongoMapper.database.collections.each do |c|
    next if c.name =~ /system/

    c.drop
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    wipe_db
  end

  config.after(:each) do
    wipe_db
  end
end
