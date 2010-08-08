require 'mongo_mapper'

# Represents an action of a worklow, kept for logging
# a transition from one state to another via an event.
# Embedded into an entity that uses a workflow
class WorkflowAction
  include MongoMapper::EmbeddedDocument

  key :user_id,         String,  :required => true
  key :event,           String,  :required => true
  key :previous_state,  String,  :required => true
  key :new_state,       String,  :required => true
  key :comment,         String
  key :created_at,      Time

  before_save :set_timestamp

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

