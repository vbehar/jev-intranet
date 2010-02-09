require 'active_ldap'
require File.dirname(__FILE__) + '/ldap_base'

# Represents a LDAP user
class User < LdapBase
  ldap_mapping :dn_attribute => 'uid', :prefix => 'ou=people', :scope => :one,
               :classes => ['top','person','organizationalPerson','inetOrgPerson',
                            'statusObject','ffckMember','extraPerson','contactPerson'],
               :sort_by => 'cn', :order => :asc
  belongs_to :groups, :class_name => 'Group', :many => 'member', :primary_key => 'dn'

  attr_mapping :user_id, :uid
  attr_mapping :name, :cn
  attr_mapping :lastname, :sn
  attr_mapping :firstname, :gn
  attr_mapping :city, :l
  attr_mapping :mobile_phone, :mobile

  date_attr :birth_date

  def age
    days = (Date.today - birth_date).to_i
    (Date.parse("1970-01-01") + days).year - 1970
  end

  def male?; gender == "M"; end
  def female?; gender == "F"; end
end

