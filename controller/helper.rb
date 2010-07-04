require 'md5'
require 'sanitize'

URL_REGEXP = /(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?[^ ]*)?/ix

helpers do 

  # return the current logged user
  def current_user
    uid = case options.environment.to_sym
      when :development; "vincent.behar"
      when :production; request.env['REMOTE_USER']
    end
    User.find(uid)
  end

  # return the full birth_date
  def birth_date(user_birth_date)
    user_birth_date.strftime("%d %B %Y") rescue ""
  end

  # return the day and month of the birth_date
  def birth_day(user_birth_date)
    user_birth_date.strftime("%d %B") rescue ""
  end

  # return the gravatar url for the given mail address
  def gravatar_for(mail, size = 80)
    encoded_mail = MD5::md5(mail.downcase) rescue nil
    "http://www.gravatar.com/avatar/#{encoded_mail}?s=#{size}&d=wavatar"
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

