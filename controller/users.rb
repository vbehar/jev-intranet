
get '/users' do
  @users = User.find(:all, :attributes => [:uid, :cn, :sn, :gn, :displayName, :title, :ffckCategory])
  erb :users
end

get '/user/:uid' do |uid|
  @user = User.find(uid)
  erb :user
end

get '/account' do
  erb :account
end

post '/account' do
  puts params['user'].inspect
  redirect '/account'
end

