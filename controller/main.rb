
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

