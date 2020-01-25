require 'rspec'
require 'pg'
require 'project'
require 'volunteer'
require 'pry'
require './config'

DB = PG.connect(TEST_DB_PARAMS)
# DB =PG.connect({:dbname => "volunteer_tracker"})

RSpec.configure do |config|
  config.after(:each) do
    DB.exec("DELETE FROM projects *;")
    DB.exec("DELETE FROM volunteers *;")
  end
end
