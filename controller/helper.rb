require 'md5'
require 'sanitize'

URL_REGEXP = /(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?[^ ]*)?/ix

helpers do 

  # return the id of the current logged user
  def current_user_id
    case options.environment.to_sym
      when :development; options.default_user_id
      when :production; request.env['REMOTE_USER']
    end
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

  # return the gravatar url for the given mail address
  def gravatar_for(mail, size = 80)
    encoded_mail = MD5::md5(mail.downcase) rescue nil
    "http://www.gravatar.com/avatar/#{encoded_mail}.jpg?s=#{size}&amp;d=wavatar"
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

