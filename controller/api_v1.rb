
before do
  parse_extension request.path_info
end

# requires sinatra >= 1.0a
#after do
#  value = convert_return_value response.body
#  response.body = value unless value.nil?
#end

get '/api/v1/users' do
  User.find(:all).to_xml
end

get '/api/v1/users/search/:attr/:value' do |attr, value|
  User.find(:all, :attribute => attr, :value => value).to_xml
end

get '/api/v1/user/:uid' do |uid|
  User.find(uid).to_xml
end

def parse_extension(request_path)
  ext_pattern = /^\/api\/v1\/.*\.([a-z]{3,4})$/
  @ext = request_path.match(ext_pattern)[1] rescue nil
  @content_type = case @ext
    when 'xml'; 'application/xml'
    when 'json'; 'application/json'
    when 'yaml'; 'text/yaml'
    else @ext = nil; nil
  end
  content_type @content_type, :charset => 'utf-8' if @content_type
end

def convert_return_value(value)
  m = "to_#{@ext}".to_sym
  return value.send(m) if value.respond_to? m
  return nil
end

