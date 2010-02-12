#!/usr/bin/env ruby

# startup file for our rack-based application
# 'rackup' in dev mode
# and whatever you want in prod

# frameworks
require 'rack'
require 'sinatra'

# config
set :environment, ENV['APP_ENV'] || :development
set :raise_errors, true

# middlewares
require 'middleware/sinatra_reloader.rb'
require 'middleware/remote_user.rb'
use ::Sinatra::Reloader if development?
use ::Rack::ShowExceptions if development?
use ::Rack::RemoteUser

# application
require 'intranet.rb'
run ::Sinatra::Application

