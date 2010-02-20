
before do
  # default values
  @title = request.path_info
  @breadcrumb = {}
  cache_control :public, :max_age => 3600

  # current user
  uid = case options.environment.to_sym
    when :development; "vincent.behar"
    when :production; request.env['REMOTE_USER']
  end
  @me = User.find(uid)
end

get '/' do
  erb :index
end

