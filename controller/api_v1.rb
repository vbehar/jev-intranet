
before do
  if request.path_info.match(/^\/api\/v1/)
    # do not cache
    expires 0, :private, :no_cache, :no_store

    # auto-set content_type, based on the extension
    ext_pattern = /^(\/api\/v1\/.*)\.([a-z]{3,4})$/
    match = request.path_info.match(ext_pattern)
    @ext = match[2] rescue nil
    @content_type = case @ext
      when 'xml'; 'application/xml'
      when 'json'; 'application/json'
      when 'yaml'; 'text/yaml'
      else @ext = nil; nil
    end
    content_type @content_type, :charset => 'utf-8' if @content_type
    request.path_info = match[1] unless @ext.nil?
  end
end

get '/api/v1/users' do
  convert_return_value User.find(:all)
end

get '/api/v1/users/:attr/:value' do |attr, value|
  convert_return_value User.find(:all, :attribute => attr, :value => value)
end

get '/api/v1/user/:uid' do |uid|
  convert_return_value User.find(uid)
end

def convert_return_value(value)
  m = "to_#{@ext}".to_sym
  value.respond_to?(m) ? value.send(m) : value.to_s rescue ""
end

