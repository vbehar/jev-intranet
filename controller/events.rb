
['/events', '/events/', '/events/:page'].each do |path|
  get path do
    expires 1.minutes, :public
    load_events(params[:page])
    erb :events
  end
end

get '/event/:slug' do |slug|
  @event = Event.find_by_slug(slug) rescue nil
  pass if @event.nil? || @event.deleted?
  erb :event
end

post '/events' do
  event = Event.new
  event.creator_uid = current_user_id
  event.r1_uid = params['r1']
  event.r1_uid = current_user_id if event.r1_uid.blank? || !User.exist?(event.r1_uid)
  event.title = clean_html(params['title'])
  event.text = clean_html(params['text'])
  event.start = params['start']
  event.end = params['end']
  if(event.save)
    redirect "/event/#{event.slug}"
  else
    redirect '/events'
  end
end

delete '/event/:id' do |id|
  event = Event.find_by_id(id) rescue nil
  pass if event.nil? || event.deleted?

  user = current_user
  halt 403 unless user.admin? || event.creator_uid.eql?(user.uid) || event.r1_uid.eql?(user.uid)

  event.deleted = true
  event.save
  halt 204
end

def load_events(page = 1, query_params = {})
  common_params = {:deleted.ne => true, :start.gte => Date.today.to_time}
  @page  = fix_page(page)
  @pages = calculate_total_pages(Event, query_params.merge(common_params), options.posts_per_page)
  @events = Event.paginate(query_params.merge(common_params).merge(:per_page => options.events_per_page,
                                                                   :page     => @page,
                                                                   :order    => :start.asc))
end

