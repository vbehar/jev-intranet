require 'md5'

helpers do 

  # return the gravatar url for the current user
  def gravatar()
    gravatar_for(@me.mail(true).first)
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

