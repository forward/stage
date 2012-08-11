require 'rubygems'

APP_ROOT = File.join(File.dirname(__FILE__), '..')
APP_ENV = ENV['RACK_ENV'] ||= "development"

require 'bundler'
Bundler.setup
Bundler.require(:default, APP_ENV) if defined?(Bundler)

require File.join(APP_ROOT, 'config', 'environments', APP_ENV)

require 'pp'
require 'matrix'
require 'time'
require 'yaml'
require 'csv'
require 'digest'
require 'mysql2'

MONGODB_CONFIG = YAML.load(File.open(APP_ROOT + '/config/mongodb.yml')).freeze
mongo = URI.parse(MONGODB_CONFIG[APP_ENV])
mongo_connection = Mongo::Connection.new(mongo.host, mongo.port)
MONGODB = mongo_connection.db(mongo.path.delete('/'))

# Load all helpers.
Dir[APP_ROOT + '/app/helpers/*.rb'].each { |file| require file }

# Load all classes.
Dir[APP_ROOT + '/app/controllers/*.rb'].each { |file| require file }