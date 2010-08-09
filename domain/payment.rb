require 'mongo_mapper'

# Represents an payment
# Embedded into an entity
class Payment
  include MongoMapper::EmbeddedDocument

  key :type,            String,   :required => true
  key :amount,          Float,    :required => true
  key :comment,         String
  key :date,            Date,     :default => Date.today
  key :created_at,      Time

  before_save :set_timestamp

  private

  # set the created_at field, only if it is nil
  def set_timestamp
    self.created_at = Time.now if self.created_at.nil?
  end

end

