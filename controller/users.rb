
get '/users' do
  @users = User.find(:all, :attributes => [:uid, :cn, :sn, :gn, :displayName, :title, :ffckCategory, :gender])
  erb :users
end

get '/user/:uid' do |uid|
  expires 0, :private, :no_cache, :no_store if uid.eql?('me')
  @user = ( uid.eql?('me') ? current_user : User.find(uid) ) rescue nil
  pass if @user.nil?
  erb :user
end

['/users/birthdays', '/users/birthdays/', '/users/birthdays/:month'].each do |path|
  get path do
    expires 1.hour, :public

    if ((not params[:month].nil?) && params[:month].to_i.between?(1,12))
      @current_month = Date.strptime params[:month], '%m'
    else
      @current_month = Date.today.at_beginning_of_month
    end

    @months_and_birthdays = -1.upto(1).collect do |i|
      month = @current_month.months_since i
      [month, users_birthdays_for(month)]
    end
    erb :users_birthdays
  end
end

# return an array of users born in the given month
def users_birthdays_for(date)
  User.find(:all, :attribute => 'birthDate', :value => date.strftime("*-%m-*"), :attributes => [:uid, :cn, :displayName, :mail, :birthDate]).sort{|a,b| a.birth_date.day <=> b.birth_date.day}
end

