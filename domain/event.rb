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
  key :closed,      Boolean, :default  => false
  key :deleted,     Boolean, :default  => false
  timestamps!

  before_validation_on_create :set_slug

  # add a new participation for the given user
  def participate(user_id, status = Participation::Status::PRESENT)
    return false if closed?
    return false unless future?
    return false unless Participation::Status.valid?(status)
    return false if user_id.nil? || !User.exist?(user_id)
    participation = participations.select{|p| p.user_id == user_id}.first
    participation = Participation.new({:user_id => user_id}) if participation.nil?
    participation.status = status
    participation.deleted = false
    participations << participation unless participations.include?participation
    true
  end

  # add a new participation for the given user, and save
  def participate!(user_id, status = Participation::Status::PRESENT)
    participate(user_id, status) ? save : false
  end

  # return true if this event has participations (whatever the status)
  def has_participations?
    participations.select{ |p| !p.deleted? }.count > 0
  end

  # return an array of participations that match the given status
  def participations_for(status)
    participations.select{ |p| p.status == status && !p.deleted? }
  end

  # mark the event as deleted, and save it
  def delete!
    self.deleted = true
    save
  end

  # mark the event as closed, and save it
  def close!
    self.closed = true
    save
  end

  # return true if this event has a duration of entire days (no hours/minutes)
  def all_day?
    self.start.getlocal.hour == 0 && self.end.getlocal.hour == 0 rescue false
  end

  # return true if this event has a duration of 1 day (or less)
  def one_day?
    self.start.strftime("%x") == self.end.strftime("%x") rescue false
  end

  # return true if this event is already passed/finished
  def passed?
    end_date = self.end.getlocal.hour == 0 ? self.end + 1.day : self.end
    end_date < Time.now
  end

  # return true if this event is occurring right now
  def occurring?
    end_date = self.end.getlocal.hour == 0 ? self.end + 1.day : self.end
    Time.now.between?(self.start, end_date)
  end

  # return true if this event is in the future
  def future?
    Time.now < self.start
  end

  # return the status of this event : 1 (passed), 2 (occurring) or 3 (future)
  def status
    return 1 if passed?
    return 2 if occurring?
    return 3 if future?
    0
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

