
class Group < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'cn',
               :prefix => 'ou=groups', :classes => ['top', 'groupOfNames'],
               :scope => :one
  has_many :members, :class_name => 'User', :wrap => 'member', :primary_key => 'dn'
end

