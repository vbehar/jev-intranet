
get '/registration/?' do
  @user = User.new
  erb :registration_form
end

get '/registration/success/?' do
  if flash[:status] == 'success'
    @uid = flash[:uid]
    @name = flash[:name]
    @mails = flash[:mails]
    expires 0, :private, :no_cache, :no_store
    erb :registration_success
  else
    redirect '/registration' 
  end
end

post '/registration/?' do
  @user = User.new
  %w(gn sn gender street postal_code l).each{|f| @user[f] = (params['user'][f].capitalize rescue nil) unless params['user'][f].blank? }
  %w(password password_verify).each{|f| @user.send("#{f}=", params['user'][f]) unless params['user'][f].blank? }
  %w(mail mobile home_phone).each{|f| @user[f] = params['user'][f] unless params['user'][f].blank? }
  %w(birth_date medical_certificate_date tetanus_vaccine_date).each{|f| @user[f] = params['user'][f] unless params['user'][f].blank? }
  %w(medical_certificate_type social_security_number occupation).each{|f| @user[f] = params['user'][f] unless params['user'][f].blank? }

  # contacts
  prefixes = %w(main_contact_ sec_contact_)
  fields = %w(name relationship mail mobile_phone home_phone).map{|e| prefixes.map{|p| p + e } }.flatten
  fields.each{|f| @user[f] = params[f] unless params[f].blank? }

  if @user.save
    s = Subscription.new
    s.user_id = @user.uid
    s.year = Subscription.current_subscription_year
    s.medical_certificate_type = @user.medical_certificate_type
    s.medical_certificate_date = @user.medical_certificate_date
    s.comment = params[:comment]
    s.save

    flash[:status] = 'success'
    flash[:uid] = @user.uid
    flash[:name] = @user.name
    flash[:mails] = @user.mail? ? @user.mail(true) : []
    redirect '/registration/success'
  else
    expires 0, :private, :no_cache, :no_store
    erb :registration_form
  end
end

