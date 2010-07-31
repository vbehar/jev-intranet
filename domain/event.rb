require 'mongo_mapper'

# Represents an event to which users can participate
class Event
  include MongoMapper::Document

  many :participations, :class_name => 'Participation'

  scope :deleted,   :deleted => true

  key :creator_uid, String,  :required => true
  key :r1_uid,      String,  :required => true
  key :slug,        String,  :required => true,  :unique => true
  key :title,       String,  :required => true
  key :text,        String
  key :start,       Time,    :required => true
  key :end,         Time,    :required => true
  key :deleted,     Boolean, :default  => false
  timestamps!

  before_validation_on_create :set_slug

  # add a new participation for the given user
  def participate!(user_id, status = Participation::Status::PRESENT)
    return if user_id.nil? || !User.exist?(user_id)
    return unless participations.select{|p| p.user_id == user_id}.empty?
    participations << Participation.new({:user_id => user_id, :status => status})
  end

  # return true if this event has participations (whatever the status)
  def has_participations?
    participations.select{ |p| !p.deleted? }.count > 0
  end

  # return an array of participations that match the given status
  def participations_for(status)
    participations.select{ |p| p.status == status && !p.deleted? }
  end

  # return true if this event has a duration of entire days (no hours/minutes)
  def all_day?
    self.start.getlocal.hour == 0 && self.end.getlocal.hour == 0 rescue false
  end

  # return true if this event has a duration of 1 day (or less)
  def one_day?
    self.start.strftime("%x") == self.end.strftime("%x") rescue false
  end

  def r1=(user)
    unless user.nil?
      self.r1_uid = user.uid
      @r1 = user
    end
  end

  def r1
    return @r1 unless @r1.nil?
    @r1 = User.find(self.r1_uid)
  end

  def creator=(user)
    unless user.nil?
      self.creator_uid = user.uid
      @creator = user
    end
  end

  def creator
    return @creator unless @creator.nil?
    @creator = User.find(self.creator_uid)
  end

  private

  # build a unique slug based on the title
  def set_slug
    title_slug = self.title.to_slug.approximate_ascii.normalize.to_s rescue 'empty'
    slug = title_slug
    tentative = 1
    while(!Event.find_by_slug(slug).nil?) do
      tentative += 1
      slug = title_slug + '-' + tentative.to_s
    end
    self.slug = slug
  end

end

