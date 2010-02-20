require 'md5'

helpers do 

  # return the full birth_date
  def birth_date(user_birth_date)
    user_birth_date.strftime("%d %B %Y") rescue ""
  end

  # return the day and month of the birth_date
  def birth_day(user_birth_date)
    user_birth_date.strftime("%d %B") rescue ""
  end

  # return the gravatar url for the given mail address
  def gravatar_for(mail)
    encoded_mail = MD5::md5(mail.downcase) rescue nil
    "http://www.gravatar.com/avatar/#{encoded_mail}?s=80"
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

