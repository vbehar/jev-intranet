
helpers do 

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

