# Our sinatra application - main entry point
# load classes and initialize connections

# extra, aka monkey patches
%w(string date).each do |f|
  require File.dirname(__FILE__) + "/extra/#{f}"
end

# domain classes
%w(user group).each do |f|
  require File.dirname(__FILE__) + "/domain/#{f}"
end

# controllers (sinatra routes)
%w(helper main account users admin api_v1).each do |f|
  require File.dirname(__FILE__) + "/controller/#{f}"
end

# initialize connections
configure do
  # ldap
  ldap_config = YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/config/ldap.yml")).result)
  ActiveLdap::Base.setup_connection ldap_config
end

