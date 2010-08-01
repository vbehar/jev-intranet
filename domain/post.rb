require 'mongo_mapper'

# Represents an update post (kind of a tweet)
class Post
  include MongoMapper::Document

  scope :deleted,      :deleted => true
  scope :from_twitter, :twitter_id.ne => nil

  key :user_id,    String,  :required => true
  key :text,       String,  :required => true
  key :twitter_id, Bignum
  key :deleted,    Boolean, :default  => false
  timestamps!

  # mark the post as deleted, and save it
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

  # return a random post
  def self.random
    Post.skip(rand(Post.count)).first
  end

end


