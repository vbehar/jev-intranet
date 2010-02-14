
get '/users' do
  @users = User.find(:all, :attributes => [:uid, :cn, :displayName, :title])
  erb :users
end

get '/user/:uid' do |uid|
  @user = User.find(uid)
  erb :user
end

get '/account' do
  erb :account
end

