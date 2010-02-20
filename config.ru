#!/usr/bin/env ruby

# startup file for our rack-based application
# 'rackup' in dev mode
# and whatever you want in prod

# frameworks
require 'rack'
require 'sinatra'

# config
ENV['RACK_ENV'] ||= ENV['APP_ENV'] # APP_ENV is used by webroar
set     :environment, ENV['RACK_ENV'] || :development
set     :raise_errors, true
enable  :sessions
disable :logging

# middlewares
configure :development do
  require 'middleware/sinatra_reloader.rb'
  use ::Sinatra::Reloader
  use ::Rack::ShowExceptions
end
configure :production do
  require 'middleware/remote_user.rb'
  use ::Rack::RemoteUser
  require 'rack/cache'
  cache_config = YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/config/cache.yml")).result)
  use Rack::Cache do
    set :verbose,           true
    set :private_headers,   []
    set :allow_reload,      true
    set :allow_revalidate,  true
    set :metastore,         cache_config['metastore']
    set :entitystore,       cache_config['entitystore']
  end
end

# application
require 'intranet.rb'
run ::Sinatra::Application

