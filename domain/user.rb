require 'active_ldap'
require File.dirname(__FILE__) + '/ldap_base'

require 'mail'
require 'erubis'

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
  attr_mapping :ffck_number_year, :ffck_number_year, :fixnum
  attr_mapping :birth_date, :birth_date, :date, :format => '%Y-%m-%d'
  attr_mapping :ffck_number_date, :ffck_number_date, :date, :format => '%Y-%m-%d'
  attr_mapping :medical_certificate_date, :medical_certificate_date, :date, :format => '%Y-%m-%d'
  attr_mapping :tetanus_vaccine_date, :tetanus_vaccine_date, :date, :format => '%Y-%m-%d'

  attr_accessor :password, :password_verify
  validate :validates_password

  validate :validates_dates

  validates_presence_of :uid, :cn, :gn, :sn, :display_name
  validates_presence_of :gender, :birth_date
  validates_presence_of :street, :postal_code, :l

  before_validation_on_create :set_uid, :set_cn, :set_default_status
  before_validation_on_create :set_ffck_category, :set_default_ffck_club

  after_validation_on_create :send_create_mail

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

  def minor?; age < 18; end
  def major?; age >= 18; end

  # return the full address of the user
  def address
    [street, [postal_code, l].join(' ')].join("\n")
  end

  # return true if the user is admin, false otherwise
  def admin?
    Group.find('admin').members.member?(self)
  end

  # return the url of the avatar image for the user, in the given size (width)
  def avatar_url(size = 80)
    encoded_mail = MD5::md5(mail(true).first.downcase) rescue nil
    "http://www.gravatar.com/avatar/#{encoded_mail}.jpg?s=#{size}&amp;d=wavatar"
  end

  private

  # custom validation : validates the password (on creation)
  def validates_password
    if user_password.blank? && password.blank?
      errors.add(:user_password, 'empty.password')
    elsif user_password.blank? && !password.blank? && password != password_verify
      errors.add(:user_password, 'invalid.password')
    elsif user_password.blank? && !password.blank? && password == password_verify
      self['user_password'] = password
    end
  end

  # custom validation : validates the format of dates
  def validates_dates
    ( Date.parse(self['birth_date']) rescue errors.add(:birth_date, 'invalid.date') ) if !self['birth_date'].blank?
    ( Date.parse(self['ffck_number_date']) rescue errors.add(:ffck_number_date, 'invalid.date') ) if !self['ffck_number_date'].blank?
    ( Date.parse(self['medical_certificate_date']) rescue errors.add(:medical_certificate_date, 'invalid.date') ) if !self['medical_certificate_date'].blank?
    ( Date.parse(self['tetanus_vaccine_date']) rescue errors.add(:tetanus_vaccine_date, 'invalid.date') ) if !self['tetanus_vaccine_date'].blank?
  end

  # set the uid based on the gn and sn values
  def set_uid
    unless gn.blank? || sn.blank?
      self['uid'] = gn.to_slug.approximate_ascii.normalize.to_s + '.' + sn.to_slug.approximate_ascii.normalize.to_s if uid.blank?
    end
  end

  # set the cn based on the gn and sn values
  def set_cn
    unless gn.blank? || sn.blank?
      self['cn'] = gn + ' ' + sn if cn.blank?
    end
  end

  # set the status to 'active' by default
  def set_default_status
    self['status'] = 'active' if status.blank?
  end

  # set the ffck_category
  def set_ffck_category
    self['ffck_category'] = calculate_ffck_category if ffck_category.blank?
  end

  # set the default ffck club name and number
  def set_default_ffck_club
    if ffck_club_number.blank? && ffck_club_name.blank?
      self['ffck_club_number'] = '9404'
      self['ffck_club_name'] = 'Joinville Eau Vive'
    end
  end

  # send a creation mail to the user
  def send_create_mail
    user = self
    unless mail(true).empty?
      Mail.deliver do
        from 'Joinville Eau Vive <webmaster@jevck.com>'
        to user.mail(true)
        subject '[JEV] Création de compte sur jevck.com'
        body Erubis::Eruby.new(File.read(File.dirname(__FILE__) + '/../views/mail_registration.erb')).result(:user => user)
      end
    end
  end

end

