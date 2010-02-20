
get '/birthdays' do
  @current_month = Date.today
  @next_month = @current_month.next_month
  @current_birthdays = users_birthdays_for @current_month
  @next_birthdays = users_birthdays_for @next_month
  erb :birthdays
end

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

# return an array of users born in the given month
def users_birthdays_for(date)
  User.find(:all, :attribute => 'birthDate', :value => date.strftime("*-%m-*"), :attributes => [:uid, :cn, :displayName, :birthDate]).sort{|a,b| a.birth_date.day <=> b.birth_date.day}
end

