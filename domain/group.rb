require 'active_ldap'
require File.dirname(__FILE__) + '/ldap_base'

# Represents a LDAP group
class Group < LdapBase
  ldap_mapping :dn_attribute => 'cn', :prefix => 'ou=groups', :scope => :one,
               :classes => ['top', 'groupOfNames'],
               :sort_by => 'cn', :order => :asc
  has_many :members, :class_name => 'User', :wrap => 'member', :primary_key => 'dn'

  attr_mapping :name, :cn
end

