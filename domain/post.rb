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

  # return an array of the most active users and their associated posts sum
  def self.most_active_users(max_users = 3)
    Post.collection.group(%w(user_id),{:deleted => false},{:count => 0},'function(doc,prev) {prev.count++;}')\
                   .sort{|a,b| b['count'] <=> a['count']}\
                   .slice(0,max_users)\
                   .map{|o| { :user => User.find(o['user_id']), :count => o['count'].to_i } }
  end

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


