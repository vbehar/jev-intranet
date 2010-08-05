
['/events/?', '/events/:type/?', '/events/:type/:page/?'].each do |path|
  get path do
    @type = params[:type].blank? ? 'future' : params[:type]
    pass unless %w(passed occurring future).include?(@type)
    now = Time.now
    query = case @type
      when 'passed'; {:end.lt => now, :order => :start.desc}
      when 'occurring'; {:start.lt => now, :end.gt => now}
      when 'future'; {:start.gt => now}
    end
    load_events(params[:page], query)
    expires 1.minutes, :public
    erb :events
  end
end

['/events/participations/:user/?', '/events/participations/:user/:page/?'].each do |path|
  get path do
    redirect "/events/participations/#{current_user_id}/#{params[:page]}" if(params[:user].eql?('mine') rescue false)
    status = params[:status].blank? ? Participation::Status::PRESENT : params[:status]
    pass unless Participation::Status.valid?(status)
    @user = User.find(params[:user]) rescue nil
    pass if @user.nil?
    load_events(params[:page], { :participations => {'$elemMatch' => {:user_id => @user.uid, :status => status, :deleted => false} }, :order => :start.desc })
    expires 1.minutes, :public
    erb :participations
  end
end

['/events/most-active-participants/?', '/events/most-active-participants/:status/?'].each do |path|
  get path do
    status = params[:status].blank? ? Participation::Status::PRESENT : params[:status]
    pass unless Participation::Status.valid?(status)
    @most_active_participants = Event.most_active_participants(options.most_active_participants_on_page, status)
    erb :most_active_participants
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
  @page  = fix_page(page)

  query = {:deleted => false, :per_page => options.events_per_page, :page => @page, :order => :start.asc}.merge(query)
  query_for_count = query.reject{|k,v| %w(per_page page order).include?(k.to_s)}

  @pages = calculate_total_pages(Event, query_for_count, options.events_per_page)
  @events = Event.paginate(query)
end

