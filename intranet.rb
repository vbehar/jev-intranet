# Our sinatra application - main entry point

# domain classes
%w(user group).each do |f|
  require File.dirname(__FILE__) + "/domain/#{f}"
end

# controllers (sinatra routes)
%w(main users).each do |f|
  require File.dirname(__FILE__) + "/controller/#{f}"
end

configure do
  # ldap config
  ldap_config = YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/config/ldap.yml")).result)
  ActiveLdap::Base.setup_connection ldap_config
end

