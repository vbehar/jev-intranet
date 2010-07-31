require 'md5'
require 'sanitize'

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

  # return the full birth_date
  def birth_date(user_birth_date)
    user_birth_date.strftime("%d %B %Y") rescue ""
  end

  # return the day and month of the birth_date
  def birth_day(user_birth_date)
    Date.strptime(user_birth_date.strftime('%d/%m'), '%d/%m').strftime("%A %d %B") rescue ""
  end

  # return an ordered array of all ffck categories
  def ffck_categories()
    %w(Pitchoun Poussin Benjamin Minime Cadet Junior Senior Veteran Inconnu)
  end

  # linkify the given text
  def linkify(text)
    text.gsub(URL_REGEXP, '<a href="\0">\0</a>') rescue text
  end

  # clean (sanitize) the given html
  def clean_html(html)
    Sanitize.clean(html) rescue html
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
    count = entity_class.send(:where, query_params.merge(:deleted.ne => true)).count
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
    0.upto(items_per_page + 1).collect{|p| offset + p }.delete_if{|p| p < 1 || p > total_pages }
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

