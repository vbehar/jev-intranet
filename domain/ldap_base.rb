require 'active_ldap'

# Base class for LDAP-based models
class LdapBase < ActiveLdap::Base

  protected

  # Map a LDAP attribute to a new name, optionaly converting it
  def self.attr_mapping(name, ldap_attr, clazz = :string, options = {})

    # override getters
    define_method(name) do
      value = self[ldap_attr.to_s]
      case clazz
        when :string; value
        when :date; Date.strptime(value, options[:format]) rescue value
        when :time; Time.parse(value) rescue value
        else value
      end
    end

    # override setters
    define_method("#{name}=") do |value|
      converted_value = case clazz
        when :string; value
        when :date; value.strftime(options[:format]) rescue value
        when :time; value.strftime(options[:format]) rescue value
        else value
      end
      self[ldap_attr.to_s] = converted_value
    end

  end

end

