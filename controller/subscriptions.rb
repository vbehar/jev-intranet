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
  @subscription = Subscription.new(:user_id => @me.uid, :year => Subscription.current_subscription_year) if Subscription.user_can_subscribe?(@me)
  erb :subscriptions
end

