
['/posts/?', '/posts/:user/?', '/posts/:user/:page/?'].each do |path|
  get path do
    redirect "/posts/#{current_user_id}/#{params[:page]}" if(params[:user].eql?('mine') rescue false)
    if params[:user].blank? || params[:user].eql?('all')
      @user = 'all'
      @user.instance_eval{ def uid(); self; end } # fake uid for constructing urls
      load_posts(params[:page])
    else
      @user = User.find(params[:user]) rescue nil
      pass if @user.nil?
      load_posts(params[:page], :user_id => @user.uid)
    end
    @most_active_users = Post.most_active_users(options.posts_most_active_users_box)
    expires 0, :private, :no_cache, :no_store
    erb :posts
  end
end

get '/posts/most-active-users/?' do
  @most_active_users = Post.most_active_users(options.posts_most_active_users_page)
  erb :posts_most_active_users
end

post '/posts/?' do
  post = Post.new
  post.user_id = current_user_id
  post.text = clean_html(params['text'])
  post.save
  redirect '/posts'
end

delete '/post/:id/?' do |id|
  post = Post.find_by_id(id) rescue nil
  pass if post.nil? || post.deleted?

  user = current_user
  halt 403 unless user.admin? || post.user_id.eql?(user.uid)

  post.delete!
  halt 204
end

def load_posts(page = 1, query = {})
  @page  = fix_page(page)

  query = {:deleted => false, :per_page => options.posts_per_page, :page => @page, :order => :created_at.desc}.merge(query)
  query_for_count = query.reject{|k,v| %w(per_page page order).include?(k.to_s)}

  @pages = calculate_total_pages(Post, query_for_count, options.posts_per_page)
  @posts = Post.paginate(query)
end

