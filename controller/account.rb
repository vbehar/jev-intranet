#
# account-related actions
# not cacheable !!
#

before do
  if request.path_info.match(/^\/account/)
    cache_control :private, :no_cache, :no_store, :max_age => 0
  end
end

get '/account.json' do
  exported_attrs = {'uid'=>'uid','cn'=>'name','sn'=>'lastname','givenName'=>'firstname','displayName'=>'displayName'}
  attrs = @me.attributes.collect{|k,v| exported_attrs.include?(k) ? [exported_attrs[k],v.to_s] : nil}.compact
  Hash[attrs].to_json
end

get '/account' do
  erb :account
end

post '/account' do
  puts params['user'].inspect
  redirect '/account'
end

