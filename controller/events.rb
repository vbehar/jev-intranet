
['/events/?', '/events/:type/?', '/events/:type/:page/?'].each do |path|
  get path do
    expires 1.minutes, :public
    now = Time.now
    @type, query = case params[:type]
      when 'passed'; ['passed', {:end.lt => now, :order => :start.desc}]
      when 'occurring'; ['occurring', {:start.lt => now, :end.gt => now}]
      else ['future', {:start.gt => now}]
    end
    load_events(params[:page], query)
    erb :events
  end
end

get '/event/:slug/?' do |slug|
  @event = Event.find_by_slug(slug) rescue nil
  pass if @event.nil? || @event.deleted?
  erb :event
end

post '/event/:slug/participation/:status/?' do |slug, status|
  pass unless Participation::Status.valid?(status)

  event = Event.find_by_slug(slug) rescue nil
  pass if event.nil? || event.deleted?

  halt 403 if event.closed?
  halt 403 unless event.future?

  halt 403 unless event.participate!(current_user_id, status)
  halt 204
end

delete '/event/:slug/participation/?' do |slug|
  event = Event.find_by_slug(slug) rescue nil
  pass if event.nil? || event.deleted?

  participation = event.participations.select{|p| p.user_id == current_user_id}.first
  pass if participation.nil? || participation.deleted?

  halt 403 if event.closed?
  halt 403 unless event.future?

  participation.delete!
  halt 204
end

post '/events/?' do
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

delete '/event/:slug/?' do |slug|
  event = Event.find_by_slug(slug) rescue nil
  pass if event.nil? || event.deleted?

  user = current_user
  halt 403 unless user.admin? || event.creator_uid.eql?(user.uid) || event.r1_uid.eql?(user.uid)

  event.delete!
  halt 204
end

def load_events(page = 1, query = {})
  query = {:deleted.ne => true, :per_page => options.events_per_page, :page => @page, :order => :start.asc}.merge(query)
  query_for_count = query.reject{|k,v| %w(per_page page order).include?(k.to_s)}

  @page  = fix_page(page)
  @pages = calculate_total_pages(Event, query_for_count, options.posts_per_page)
  @events = Event.paginate(query)
end

