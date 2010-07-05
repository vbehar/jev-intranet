
['/posts', '/posts/', '/posts/:user', '/posts/:user/', '/posts/:user/:page'].each do |path|
  get path do
    if params[:user].nil? || params[:user].eql?('all')
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

def load_posts(page = 1, query_params = {})
  @page = page.to_i
  @page = 1 unless @page.is_a?(Fixnum) && @page > 0
  posts_count = Post.where(query_params.merge(:deleted.ne => true)).count
  @pages = posts_count / options.posts_per_page
  @pages += 1 if (posts_count % options.posts_per_page) > 0
  @posts = Post.paginate(query_params.merge(:per_page => options.posts_per_page, :page => @page,
                                            :deleted.ne => true, :order => :created_at.desc))
end

