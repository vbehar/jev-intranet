
before do
  # default values
  @title = request.path_info
  @breadcrumb = {}

  # default cache
  if(request.get? || request.head?)
    expires 10.minutes, :public
  else
    expires 0, :private, :no_cache, :no_store
  end
end

get '/' do
  redirect '/posts'
end

get '/about/?' do
  erb :about
end

get '/resources/?' do
  erb :resources
end

get '/paddle-pass/?' do
  erb :paddle_pass
end

get '/services/?' do
  erb :services
end

# error handling

get '/500/?' do
  raise 'fake error from /500'
end

error do
  e = env['sinatra.error']
  trace = e.backtrace.delete_if{|t| t.start_with?('/var/lib/gems')}.join("\n") rescue nil
  logger.error "500 at #{request.path_info}\n#{e.class} : #{e.message}\n#{trace}"
  erb :error_500
end

not_found do
  logger.error '404 at ' + request.path_info
  erb :error_404
end

