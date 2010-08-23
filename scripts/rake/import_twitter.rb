# rake tasks for importing tweets in posts

require 'httparty'

namespace :twitter do
  namespace :import do

    desc "Import jevck's tweets into posts"
    task :jevck do
      twitter_api = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=jevck&count=200&trim_user=true"

      last_tweet = Post.from_twitter.where(:user_id => "jev").sort(:created_at).last
      if last_tweet.nil?
        # we need to import all tweets
        page = 1
        tweets = []
        begin
          tweets = HTTParty.get(twitter_api + "&page=" + page.to_s)
          import_tweets tweets
          page += 1
        end while not tweets.empty?
      else
        # let's just retrieve newest tweets
        import_tweets HTTParty.get(twitter_api + "&since_id=" + last_tweet.twitter_id.to_s)
      end

    end

  end 
end

# convert tweets to posts and save them
def import_tweets(tweets)
  # check for errors before importing
  if tweets.is_a?(Hash) && (not tweets["error"].nil?)
    $stderr.puts tweets
    return
  end

  tweets.each do |tweet|
    post = Post.new
    post.user_id = "jev"
    post.twitter_id = tweet["id"].to_i
    post.created_at = Time.parse(tweet["created_at"])
    post.text = tweet["text"]
    post.save
  end
end

