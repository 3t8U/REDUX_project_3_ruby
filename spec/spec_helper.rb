require 'rspec'
require 'pg'
require 'project'
require 'volunteer'
require 'pry'
require './config'

DB = PG.connect(TEST_DB_PARAMS)

RSpec.configure do |config|
  config.after(:each) do
    DB.exec("DELETE FROM projects *;")
    DB.exec("DELETE FROM volunteers *;")
    DB.exec("DELETE FROM projects_volunteers *;")
  end
end
