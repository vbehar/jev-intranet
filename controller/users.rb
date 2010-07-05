
get '/users' do
  @users = User.find(:all, :attributes => [:uid, :cn, :sn, :gn, :displayName, :title, :ffckCategory, :gender])
  erb :users
end

get '/user/:uid' do |uid|
  @user = User.find(uid)
  erb :user
end

get '/users/birthdays' do
  expires 1.hour, :public

  current_month = Date.today
  next_month = current_month.next_month
  @months_and_birthdays = [ [current_month, users_birthdays_for(current_month)],
                            [next_month,    users_birthdays_for(next_month)] ]
  erb :users_birthdays
end

# return an array of users born in the given month
def users_birthdays_for(date)
  User.find(:all, :attribute => 'birthDate', :value => date.strftime("*-%m-*"), :attributes => [:uid, :cn, :displayName, :birthDate]).sort{|a,b| a.birth_date.day <=> b.birth_date.day}
end

