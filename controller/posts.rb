
['/posts', '/posts/', '/posts/:user', '/posts/:user/', '/posts/:user/:page'].each do |path|
  get path do
    if params[:user].blank? || params[:user].eql?('all')
      expires 1.minutes, :public
      @user = 'all'
      load_posts(params[:page])
    else
      expires 0, :private, :no_cache, :no_store
      @user = ( params[:user].eql?('mine') ? current_user_id : params[:user] )
      load_posts(params[:page], :user_id => @user)
    end
    erb :posts
  end
end

post '/posts' do
  post = Post.new
  post.user_id = current_user_id
  post.text = clean_html(params['text'])
  post.save
  redirect '/posts'
end

delete '/post/:id' do |id|
  @post = Post.find_by_id(id) rescue nil
  pass if @post.nil? || @post.deleted?

  @user = current_user
  halt 403 unless @user.admin? || @post.user_id.eql?(@user.uid)

  @post.deleted = true
  @post.save
  halt 204
end

def load_posts(page = 1, query_params = {})
  common_params = {:deleted.ne => true}
  @page  = fix_page(page)
  @pages = calculate_total_pages(Post, query_params.merge(common_params), options.posts_per_page)
  @posts = Post.paginate(query_params.merge(common_params).merge(:per_page => options.posts_per_page,
                                                                 :page     => @page,
                                                                 :order    => :created_at.desc))
end

