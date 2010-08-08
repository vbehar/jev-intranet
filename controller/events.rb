
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

post '/event/:slug/?' do |slug|
  @event = Event.find_by_slug(slug) rescue nil
  pass if @event.nil? || @event.deleted?

  user = current_user
  halt 403 unless user.admin? || @event.creator_uid.eql?(user.uid) || @event.r1_uid.eql?(user.uid)

  %w(title text).each{ |f| @event[f] = clean_html(clean_input(params['event'][f])) }
  %w(start end r1_uid).each{ |f| @event[f] = params['event'][f] }
  start_time = Time.parse(params['event']['start_time']) rescue nil unless params['event']['start_time'].blank?
  @event.start += start_time.hour.hours + start_time.min.minutes unless start_time.nil?
  end_time = Time.parse(params['event']['end_time']) rescue nil unless params['event']['end_time'].blank?
  @event.end += end_time.nil? ? 1.day - 1.second : end_time.hour.hours + end_time.min.minutes
  @event.r1_uid = current_user_id if @event.r1_uid.blank? || !User.exist?(@event.r1_uid)

  @event.closed = (params['event']['closed'] == 'on')

  if(@event.save)
    redirect "/event/#{slug}"
  else
    @users = User.find(:all, :attributes => ['cn','uid','displayName']).map{|u| {:uid => u.uid, :display_name => u.display_name}}
    @new = false
    expires 0, :private, :no_cache, :no_store
    erb :event_form
  end
end

get '/event/:slug/edit/?' do |slug|
  @event = Event.find_by_slug(slug) rescue nil
  pass if @event.nil? || @event.deleted?

  user = current_user
  halt 403 unless user.admin? || @event.creator_uid.eql?(user.uid) || @event.r1_uid.eql?(user.uid)

  @users = User.find(:all, :attributes => ['cn','uid','displayName']).map{|u| {:uid => u.uid, :display_name => u.display_name}}
  @new = false
  expires 0, :private, :no_cache, :no_store
  erb :event_form
end

get '/events/new' do
  @event = Event.new
  @event.start = @event.end = @event.created_at = @event.updated_at = Time.now
  @event.r1_uid = @event.creator_uid = current_user_id

  @users = User.find(:all, :attributes => ['cn','uid','displayName']).map{|u| {:uid => u.uid, :display_name => u.display_name}}
  @new = true
  erb :event_form
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
  @event = Event.new

  %w(title text).each{ |f| @event[f] = clean_html(clean_input(params['event'][f])) }
  %w(start end r1_uid).each{ |f| @event[f] = params['event'][f] }
  start_time = Time.parse(params['event']['start_time']) rescue nil unless params['event']['start_time'].blank?
  @event.start += start_time.hour.hours + start_time.min.minutes unless start_time.nil?
  end_time = Time.parse(params['event']['end_time']) rescue nil unless params['event']['end_time'].blank?
  @event.end += end_time.nil? ? 1.day - 1.second : end_time.hour.hours + end_time.min.minutes
  @event.r1_uid = current_user_id if @event.r1_uid.blank? || !User.exist?(@event.r1_uid)

  @event.closed = (params['event']['closed'] == 'on')

  if(@event.save)
    redirect "/event/#{@event.slug}"
  else
    @new = true
    @event.created_at = @event.updated_at = Time.now
    @event.creator_uid = current_user_id
    @users = User.find(:all, :attributes => ['cn','uid','displayName']).map{|u| {:uid => u.uid, :display_name => u.display_name}}
    expires 0, :private, :no_cache, :no_store
    erb :event_form
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

