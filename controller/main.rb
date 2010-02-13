
before do
  # default values
  @breadcrumb = request.path_info
  @title = request.path_info

  # current user
  uid = "vincent.behar" #request.env['REMOTE_USER']
  @me = User.find(uid)
end

get '/' do
  @title = @breadcrumb = "Accueil"
  erb :index
end

