
get '/groups' do
  Group.find(:all).collect{|g| g.name + "<br>"}.to_s
end

get '/users' do
  User.find(:all).collect{|u| u.name + "<br>"}.to_s
end

