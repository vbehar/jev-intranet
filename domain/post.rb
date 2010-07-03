require 'mongo_mapper'

# Represents an update post (kind of a tweet)
class Post
  include MongoMapper::Document

  key :user_id, String
  key :text, String
  key :twitter_id, Bignum
  timestamps!

  def user=(user)
    write_key(:user_id, user.user_id) unless user.nil?
  end

  def user
    User.find(user_id) 
  end

end


