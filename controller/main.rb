
before do
  # default values
  @title = request.path_info
  @breadcrumb = {}

  # default cache
  expires 1.hour, :public
end

get '/' do
  erb :index
end

