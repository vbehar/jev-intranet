
before do
  #case request.path_info.match /^\/api\/v1\/([a-z]{3,4})\//
  if request.path_info.match /^\/api\/v1/
    content_type 'application/xml', :charset => 'utf-8'
  end
end

get '/api/v1/users' do
  User.find(:all).to_xml
end

get '/api/v1/users/search/:attr/:value' do |attr, value|
  User.find(:all, :attribute => attr, :value => value).to_xml
end

get '/api/v1/user/:uid' do |uid|
  User.find(uid).to_xml
end


