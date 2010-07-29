require 'mongo_mapper'

# Represents a user's participation to an event
# embedded into an event
class Participation

  class Status
    PRESENT = 'present'
    ABSENT  = 'absent'
    UNKNOWN = 'unknown'
  end

  include MongoMapper::EmbeddedDocument
  plugin MongoMapper::Plugins::Timestamps

  key :user_id,     String,  :required => true
  key :status,      String,  :required => true
  key :deleted,     Boolean, :default  => false
  timestamps!

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

end

