
before do
  # default values
  @title = request.path_info
  @breadcrumb = {}

  # current user
  uid = "vincent.behar" #request.env['REMOTE_USER']
  @me = User.find(uid)
end

get '/' do
  erb :index
end

