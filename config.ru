#!/usr/bin/env ruby

# startup file for our rack-based application
# 'shotgun config.ru' in dev mode
# and whatever you want in prod

# frameworks
require 'rack'
require 'sinatra'

# config
#set :environment, ENV['APP_ENV'] || :production
set :raise_errors, true

# middlewares
require 'middleware/remote_user.rb'
use Rack::ShowExceptions
use Rack::RemoteUser

# application
require 'intranet.rb'
run Sinatra::Application

