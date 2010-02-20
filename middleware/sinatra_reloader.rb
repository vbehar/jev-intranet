
# reload sinatra routes in dev mode
class Sinatra::Reloader < ::Rack::Reloader
  def safe_load(file, mtime, stderr = $stderr)
    ::Sinatra::Application.reset!
    stderr.puts "#{self.class}: reseting routes"
    super
  end
end

