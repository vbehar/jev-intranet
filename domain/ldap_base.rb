
class LdapBase < ActiveLdap::Base

  protected
  def self.attr_mapping(name, ldap_attr)
    define_method name do
      send(ldap_attr)
    end
  end

end

