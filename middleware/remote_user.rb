require 'rack'

module Rack

  # enable REMOTE_USER as a shortcut to HTTP_AUTH_USER
  class RemoteUser
    def initialize app
      @app = app
    end

    def call env
      env['REMOTE_USER'] = env['HTTP_AUTH_USER'] if env['HTTP_AUTH_USER']
      @app.call env
    end
  end

end

