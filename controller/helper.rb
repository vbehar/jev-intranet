URL_REGEXP = /(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?[^ ]*)?/ix

helpers do 

  # return the id of the current logged user
  def current_user_id
    uid = case options.environment.to_sym
      when :development; options.default_user_id
      when :production; request.env['REMOTE_USER']
    end
    # allow user-switching only if the real current user (uid) is admin
    unless session['logged-user'].blank?
      uid = User.find(session['logged-user']).uid rescue uid if User.find(uid).admin?
    end
    uid
  end

  # return the current logged user
  def current_user
    User.find(current_user_id)
  end

  # return the configured Logger instance
  def logger
    options.logger
  end

  # return a formatted string representing a duration between the 2 given dates
  def duration_date(start_date, end_date)
    str = ""

    start_date = start_date.to_time if start_date.respond_to?('to_time')
    end_date = end_date.to_time if end_date.respond_to?('to_time')

    if start_date.is_a?(Time) && end_date.is_a?(Time)

      start_date = start_date.getlocal if start_date.utc?
      end_date = end_date.getlocal if end_date.utc?

      if start_date.strftime("%x") == end_date.strftime("%x") # same day
        str += start_date.strftime "Le %A %d %B %Y"
        if start_date.strftime("%X") == "00:00:00" && end_date.strftime("%X") == "23:59:59"
          # entire day - no need to display start/end times
        elsif end_date.strftime("%X") == "23:59:59" # we only have a start time
          str += start_date.strftime " à partir de %Hh%M"
        elsif start_date.strftime("%X") == "00:00:00" # we only have an end time
          str += end_date.strftime " jusqu'à %Hh%M"
        else # we have both a start and an end time
          str += start_date.strftime " de %Hh%M"
          str += end_date.strftime " à %Hh%M"
        end

      else # different days
        str += start_date.strftime "Du %A %d %B %Y"
        str += start_date.strftime " (%Hh%M)" if start_date.strftime("%X") != "00:00:00"
        str += end_date.strftime " au %A %d %B %Y"
        str += end_date.strftime " (%Hh%M)" if end_date.strftime("%X") != "23:59:59"
      end
    end
    str
  end

  # return the full birth_date
  def birth_date(user_birth_date)
    user_birth_date.strftime("%d %B %Y") rescue ""
  end

  # return the day and month of the birth_date
  def birth_day(user_birth_date)
    Date.strptime(user_birth_date.strftime('%d/%m'), '%d/%m').strftime("%A %d %B") rescue ""
  end

  # return a string representing the level of the poster, based on his posts count and the max count
  def poster_level(poster_count, max_count)
    levels = %w(Blanche Jaune Verte Bleue Rouge Noire)
    step = max_count / ( levels.length - 1 )
    step = 1 if step == 0
    level = poster_count / step
    'Pagaie ' + levels[level]
  end

  # return a string representing the level of the participant, based on his participations count and the max count
  alias :participant_level :poster_level

  # return an ordered array of all ffck categories
  def ffck_categories()
    %w(Pitchoun Poussin Benjamin Minime Cadet Junior Senior Veteran Inconnu)
  end

  # linkify the given text
  def linkify(text)
    text.gsub(URL_REGEXP, '<a href="\0">\0</a>') rescue text
  end

  # transform all 'lines returns' into html 'br'
  def nl2br(text)
    text.gsub(/\n/, '<br />') rescue text
  end

  # clean (sanitize) the given html
  def clean_html(html)
    Sanitize.clean(html) rescue html
  end

  # clean the given input text (remove bad characters)
  def clean_input(text)
    text.gsub(/\r/, '') rescue text
  end

  # pagination - fix actual page number (start at 1)
  def fix_page(page)
    page = page.to_i rescue 1
    page = 1 unless page.is_a?(Fixnum) && page > 0
    page
  end

  # pagination - calculate the total number of pages
  # for the given entity_class and associated query
  def calculate_total_pages(entity_class, query_params = {}, items_per_page = 10)
    return nil unless !entity_class.nil? && entity_class.respond_to?(:where)
    query = entity_class.where(query_params)
    return nil unless !query.nil? && query.respond_to?(:count)
    count = query.count
    pages = count / items_per_page
    pages += 1 if (count % items_per_page) > 0
    pages
  end

  # return an array of pages to display for pagination
  # based on the current_page (number)
  def pagination(current_page, items_per_page, total_pages)
    index = current_page % items_per_page
    offset = current_page - index
    offset -= items_per_page if index == 0
    0.upto(items_per_page + 1).map{|p| offset + p }.delete_if{|p| p < 1 || p > total_pages }
  end

  # ADMIN HELPERS

  # retrieve the uid of the previous user (based on the list of users present in session)
  def prev_user(current_user = nil)
    users = session["users"]
    current_idx = users.index(current_user) rescue nil
    users[current_idx - 1] rescue nil
  end

  # retrieve the uid of the next user (based on the list of users present in session)
  def next_user(current_user = nil)
    users = session["users"]
    current_idx = users.index(current_user) rescue nil
    users[current_idx + 1] rescue nil
  end

end

