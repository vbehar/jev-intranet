require 'mongo_mapper'

# Represents an event to which users can participate
class Event
  include MongoMapper::Document

  many :participations, :class_name => 'Participation'

  scope :deleted,   :deleted => true

  key :creator_uid, String,  :required => true
  key :r1_uid,      String,  :required => true
  key :title,       String,  :required => true
  key :text,        String
  key :start,       Time,    :required => true
  key :end,         Time,    :required => true
  key :deleted,     Boolean, :default  => false
  timestamps!

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

end

