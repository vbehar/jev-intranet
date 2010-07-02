
before do
  # default values
  @title = request.path_info
  @breadcrumb = {}

  # default cache
  expires 10.minutes, :public
end

get '/' do
  @posts = Post.all
  erb :index
end

get '/about' do
  erb :about
end

