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
  attr_mapping :birth_date, :birth_date, :date
  attr_mapping :ffck_number_date, :ffck_number_date, :date
  attr_mapping :medical_certificate_date, :medical_certificate_date, :date

  # search users with the given params (:filter and :attributes)
  def self.search_users(params = {})
    self.search(params).map do |user|
      attrs = user[1].to_a
      # don't use an array for uid
      attrs.map!{ |k,v| k == 'uid' ? [k,v.to_s] : [k,v] }
      User.new(Hash[attrs])
    end
  end

  # return the actual age of the user
  def age
    return nil if birth_date.nil?
    days = (Date.today - birth_date).to_i
    (Date.parse('1970-01-01') + days).year - 1970
  end

  # return the category for the current season
  def calculate_ffck_category
    season_year = Date.today.month >= 8 ? Date.today.year + 1 : Date.today.year
    user_birth_year = birth_date.year rescue Date.today.year
    case season_year - user_birth_year
      when 0..8; 'Pitchoun'
      when 9; 'Poussin 1'
      when 10; 'Poussin 2'
      when 11; 'Benjamin 1'
      when 12; 'Benjamin 2'
      when 13; 'Minime 1'
      when 14; 'Minime 2'
      when 15; 'Cadet 1'
      when 16; 'Cadet 2'
      when 17; 'Junior 1'
      when 18; 'Junior 2'
      when 19..34; 'Senior'
      when 35..39; 'Veteran 1'
      when 40..44; 'Veteran 2'
      when 45..49; 'Veteran 3'
      when 50..999; 'Veteran +'
      else 'Inconnu'
    end
  end

  def male?; gender == 'M'; end
  def female?; gender == 'F'; end

  # return true if the user is admin, false otherwise
  def admin?
    Group.find('admin').members.member?(self)
  end

  # return the url of the avatar image for the user, in the given size (width)
  def avatar_url(size = 80)
    encoded_mail = MD5::md5(mail(true).first.downcase) rescue nil
    "http://www.gravatar.com/avatar/#{encoded_mail}.jpg?s=#{size}&amp;d=wavatar"
  end

  # return all posts that belongs to the user
  def posts
    Post.where(:user_id => user_id).all
  end

end

