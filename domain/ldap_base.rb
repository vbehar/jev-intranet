require 'active_ldap'

# Base class for LDAP-based models
class LdapBase < ActiveLdap::Base

  protected

  # Map a LDAP attribute to a new name, optionaly converting it
  def self.attr_mapping(name, ldap_attr, clazz = :string, options = {})
    define_method name.to_sym do
      value = self[ldap_attr.to_s]
      case clazz
        when :string; value
        when :date; Date.strptime(value, options[:format]) rescue nil
        when :time; Time.parse(value) rescue nil
        else nil
      end
    end
  end

end

