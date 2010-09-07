
get '/users/?' do
  @users = User.find(:all, :attributes => [:uid, :cn, :sn, :gn, :displayName, :title, :ffckCategory, :gender])
  erb :users
end

get '/user/:uid/?' do |uid|
  redirect "/user/#{current_user_id}" if uid.eql?('me')
  @user = User.find(uid) rescue nil
  pass if @user.nil?
  @posts = Post.where(:user_id => @user.uid, :deleted => false).count
  @participations = Event.where(:participations => {'$elemMatch' => {:user_id => @user.uid,
                                                                     :status => Participation::Status::PRESENT,
                                                                     :deleted => false} },
                                :deleted => false).count
  erb :user
end

['/users/birthdays/?', '/users/birthdays/:month/?'].each do |path|
  get path do
    expires 1.hour, :public

    if ((not params[:month].blank?) && params[:month].to_i.between?(1,12))
      @current_month = Date.strptime params[:month], '%m'
    else
      @current_month = Date.today.at_beginning_of_month
    end

    @months_and_birthdays = -1.upto(1).map do |i|
      month = @current_month.months_since i
      [month, users_birthdays_for(month)]
    end
    erb :users_birthdays
  end
end

# return an array of users born in the given month
def users_birthdays_for(date)
  User.find(:all, :attribute => 'birthDate', :value => date.strftime('*-%m-*', 'fr'), :attributes => [:uid, :cn, :displayName, :mail, :birthDate]).sort{|a,b| a.birth_date.day <=> b.birth_date.day}
end

