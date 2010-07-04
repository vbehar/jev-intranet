#
# account-related actions
# not cacheable !!
#

before do
  if request.path_info.match(/^\/account/)
    # do not cache
    expires 0, :private, :no_cache, :no_store

    @me = current_user
  end
end

get '/account.json' do
  content_type 'application/json', :charset => 'utf-8'
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

