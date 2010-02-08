
class LdapBase < ActiveLdap::Base

  protected

  def self.attr_mapping(name, ldap_attr)
    define_method name.to_sym do
      self[ldap_attr.to_s]
    end
  end

  def self.date_attr(name)
    define_method name.to_sym do
      value = self[name.to_s]
      Date.parse(value)
    end
  end

end

