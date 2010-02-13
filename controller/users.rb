
get '/groups' do
  @list = Group.find(:all).collect{|g| g.name }
  erb :list
end

get '/users' do
  @users = User.find(:all, :attributes => [:uid, :cn, :title])
  erb :users
end

get '/user/:uid' do |uid|
  @user = User.find(uid)
  @title = @user.name
  @breadcrumb = "Adhérents > #{@user.name}"
  erb :user
end

