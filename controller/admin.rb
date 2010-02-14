
get '/admin' do
  erb :admin_index
end

get '/admin/about' do
  "Environment : " + ( options.environment.to_s rescue "undefined" )
end

