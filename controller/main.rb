
before do
  uid = "vincent.behar" #request.env['REMOTE_USER']
  @me = User.find(uid)
end

get '/' do
  erb :index
end

