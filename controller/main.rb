
before do
  # default values
  @title = request.path_info
  @breadcrumb = {}

  # default cache
  expires 10.minutes, :public
end

get '/' do
  erb :index
end

