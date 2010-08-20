#
# subscriptions-related actions
# not cacheable !!
#

before do
  if request.path_info.match(/^\/subscriptions/)
    # do not cache
    expires 0, :private, :no_cache, :no_store

    @me = current_user
  end
end

get '/subscriptions/?' do
  @subscriptions = Subscription.where(:user_id => @me.uid).sort(:year.desc).all
  @subscription = Subscription.find_or_create(:user_id => @me.id, :year => Subscription.current_subscription_year)
  erb :subscriptions
end

get '/subscriptions/:year/?' do |year|
  year = year.to_i rescue Subscription.current_subscription_year
  pass unless year.between?(options.first_subscription_year, Subscription.current_subscription_year)
  @subscription = Subscription.find_or_create(:user_id => @me.id, :year => year)
  erb :subscription
end

post '/subscriptions/:year/?' do |year|
  year = year.to_i rescue Subscription.current_subscription_year
  pass unless year.between?(options.first_subscription_year, Subscription.current_subscription_year)
  @subscription = Subscription.find_or_create(:user_id => @me.id, :year => year)
  halt 403 unless @subscription.editable_by_user?

  %w(medical_certificate_type medical_certificate_date comment).each{ |f| @subscription[f] = clean_input(params['subscription'][f]) }
  if(@subscription.save)
    redirect '/subscriptions'
  else
    erb :subscription
  end
end

