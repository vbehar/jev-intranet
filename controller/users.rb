
get '/groups' do
  @list = Group.find(:all).collect{|g| g.name }
  erb :list
end

get '/users' do
  @list = User.find(:all).collect{|u| u.name }
  erb :list
end

