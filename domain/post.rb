require 'mongo_mapper'

# Represents an update post (kind of a tweet)
class Post
  include MongoMapper::Document

  scope :deleted,      :deleted => true
  scope :from_twitter, :twitter_id.ne => nil

  key :user_id,    String
  key :text,       String
  key :twitter_id, Bignum
  key :deleted,    Boolean
  timestamps!

  def user=(user)
    self.user_id = user.user_id unless user.nil?
  end

  def user
    User.find(self.user_id)
  end

  # return a random post
  def self.random
    Post.skip(rand(Post.count)).first
  end

end


