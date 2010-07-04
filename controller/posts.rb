
['/posts', '/posts/', '/posts/:page'].each do |path|
  get path do
    expires 1.minutes, :public
    load_posts(params[:page])
    erb :posts
  end
end

post '/posts' do
  post = Post.new
  post.user = current_user
  post.text = clean_html(params['text'])
  post.save
  redirect '/posts'
end

def load_posts(page = 1)
  @page = page.to_i
  @page = 1 unless @page.is_a?(Fixnum) && @page > 0
  posts_count = Post.count
  @pages = posts_count / options.posts_per_page
  @pages += 1 if (posts_count % options.posts_per_page) > 0
  @posts = Post.paginate(:per_page => options.posts_per_page, :page => @page, :order => :created_at.desc)
end

