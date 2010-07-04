
POSTS_PER_PAGE = 10

before do
  # default values
  @title = request.path_info
  @breadcrumb = {}
  @full_width = true

  # default cache
  if(request.get? || request.head?)
    expires 10.minutes, :public
  else
    expires 0, :private, :no_cache, :no_store
  end
end

['/', '/posts', '/posts/'].each do |path|
  get path do
    display_posts(params[:page])
  end
end
get '/posts/:page' do |page|
  display_posts(page)
end

post '/posts' do
  post = Post.new
  post.user = current_user
  post.text = params['text']
  post.save
  redirect '/posts'
end

get '/about' do
  erb :about
end

def display_posts(page)
  @page = page.to_i
  @page = 1 unless @page.is_a?(Fixnum) && @page > 0
  posts_count = Post.count
  @pages = posts_count / POSTS_PER_PAGE
  @pages += 1 if (posts_count % POSTS_PER_PAGE) > 0
  @posts = Post.sort(:created_at.desc).limit(POSTS_PER_PAGE).skip((@page-1)*POSTS_PER_PAGE).all
  erb :index
end

