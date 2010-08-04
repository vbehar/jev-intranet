require 'mongo_mapper'

# Represents a user's participation to an event
# embedded into an event
class Participation

  class Status
    PRESENT = 'present'
    ABSENT  = 'absent'
    UNKNOWN = 'unknown'

    # return an array of all statuses
    def self.all
      self.constants.map{|s| eval s}
    end

    # return true if the given status is valid
    def self.valid?(status)
      self.all.include?(status)
    end
  end

  include MongoMapper::EmbeddedDocument

  key :user_id,     String,  :required => true
  key :status,      String,  :required => true
  key :deleted,     Boolean, :default  => false
  key :created_at,  Time

  before_save :set_timestamp

  # mark the participation as deleted, and save it
  def delete!
    self.deleted = true
    save
  end

  def user=(user)
    unless user.nil?
      self.user_id = user.user_id
      @user = user
    end
  end

  def user
    return @user unless @user.nil?
    @user = User.find(self.user_id)
  end

  private

  # set the created_at field, only if it is nil
  def set_timestamp
    self.created_at = Time.now if self.created_at.nil?
  end

end

