require 'mongo_mapper'

# Represents an update post (kind of a tweet)
class Post
  include MongoMapper::Document

  key :text, String
  key :user_id, String
  timestamps!

  def user=(user)
    write_key(:user_id, user.user_id) unless user.nil?
  end

  def user
    User.find(user_id) 
  end

end


