#!/usr/bin/env ruby

# startup file for our rack-based application
# 'rackup' or 'shotgun config.ru' in dev mode
# and whatever you want in prod (tested with webroar)

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
use ::Rack::ShowExceptions
configure :development do
  require File.dirname(__FILE__) + '/middleware/sinatra_reloader'
  use ::Sinatra::Reloader
end
configure :production do
  cache_config = YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/config/cache.yml")).result)
  if cache_config['active']
    require 'rack/cache'
    use ::Rack::Cache,
      :verbose            => true,
      :default_ttl        => 0,
      :private_headers    => [],
      :allow_reload       => false,
      :allow_revalidate   => false,
      :metastore          => cache_config['metastore'],
      :entitystore        => cache_config['entitystore']
  end
  require 'rack/contrib'
  use ::Rack::ETag
  require File.dirname(__FILE__) + '/middleware/remote_user'
  use ::Rack::RemoteUser
end

# application
require File.dirname(__FILE__) + '/intranet'
run ::Sinatra::Application

