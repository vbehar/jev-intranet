
get '/admin' do
  erb :admin_index
end

get '/admin/about' do
  "Environment : " + ( options.environment.to_s rescue "undefined" )
end

get '/admin/users' do
  @users = User.find(:all)

  session["users"] = @users.collect{|u| u.uid}
  erb :admin_users
end

post '/admin/users' do
  @filter = params[:filter]
  @users = User.search_users(:filter => @filter)
  @users.sort!{ |a,b| a.uid <=> b.uid }

  session["users"] = @users.collect{|u| u.uid}
  erb :admin_users
end

get '/admin/user/:uid' do |uid|
  @user = User.find(uid)
  erb :admin_user
end

