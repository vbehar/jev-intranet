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
  exported_attrs = {'uid'=>'uid','cn'=>'name','sn'=>'lastname','givenName'=>'firstname','displayName'=>'display_name'}
  attrs = Hash[@me.attributes.map{|k,v| exported_attrs.include?(k) ? [exported_attrs[k],v.to_s] : nil}.compact]
  attrs['is_admin'] = @me.admin?
  attrs.to_json
end

get '/account/?' do
  erb :account
end

get '/account/avatar/?' do
  erb :account_avatar
end

get '/account/contact/?' do
  erb :account_contact
end

post '/account/contact/?' do
  fields = %w(display_name gender street postal_code l title occupation social_security_number birth_date tetanus_vaccine_date)
  fields.each{|f| @me[f] = params['user'][f] }
  multi_fields = %w(mail mobile home_phone telephone_number labeled_uri)
  multi_fields.each{|f| @me[f] = params['user'][f] }
  if @me.save
    redirect '/account'
  else
    erb :account_contact
  end
end

get '/account/contacts/?' do
  erb :account_contacts
end

post '/account/contacts/?' do
  prefixes = %w(main_contact_ sec_contact_)
  fields = %w(name relationship mail mobile_phone home_phone).map{|e| prefixes.map{|p| p + e } }.flatten
  fields.each{|f| @me[f] = params[f] }
  if @me.save
    redirect '/account'
  else
    erb :account_contacts
  end
end

