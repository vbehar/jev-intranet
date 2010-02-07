
class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid', :prefix => 'ou=people',
               :classes => ['top','person','organizationalPerson','inetOrgPerson',
                            'statusObject','ffckMember']
  belongs_to :groups, :class_name => 'Group', :many => 'member', :primary_key => 'dn'
end

