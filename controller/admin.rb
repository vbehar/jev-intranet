require 'fastercsv'

#
# admin-related actions
# not cacheable !!
#

before do
  if request.path_info.match(/^\/admin/)
    # do not cache
    expires 0, :private, :no_cache, :no_store
  end
end

get '/admin/?' do
  erb :admin_index
end

get '/admin/login-as/:login_as/?' do |login_as|
  session['logged-user'] = ( login_as.eql?('me') ? nil : login_as )
  redirect '/user/me'
end

get '/admin/users.csv' do
  content_type 'text/csv', :charset => 'utf-8'
  FasterCSV.generate(:col_sep => ";") do |csv|
    csv << %w( uid firstname lastname displayName status
               ffckNumber ffckNumberYear ffckNumberDate ffckCategory ffckClubNumber ffckClubName
               medicalCertificateDate medicalCertificateType socialSecurityNumber tetanusVaccineDate
               gender birthDate occupation title description
               address postalCode city
               mail homePhone mobilePhone proPhone fax
               mainContactName mainContactPhone mainContactHomePhone mainContactMobilePhone mainContactMail mainContactRelationship
               secContactName secContactPhone secContactHomePhone secContactMobilePhone secContactMail secContactRelationship )
    User.find(:all).each do |u|
      csv << [ u.uid, u.firstname, u.lastname, u.display_name, u.status,
               u.ffck_number, u.ffck_number_year, u.ffck_number_date, u.ffck_category, u.ffck_club_number, u.ffck_club_name,
               u.medical_certificate_date, u.medical_certificate_type, u.social_security_number, u.tetanus_vaccine_date,
               u.gender, u.birth_date, u.occupation, u.title, u.description,
               u.street, u.postal_code, u.l,
               u.mail(true).join('|'), u.home_phone(true).join('|'), u.mobile(true).join('|'), u.telephone_number(true).join('|'), u.fax,
               u.main_contact_name, u.main_contact_phone, u.main_contact_home_phone, u.main_contact_mobile_phone, u.main_contact_mail, u.main_contact_relationship,
               u.sec_contact_name, u.sec_contact_phone, u.sec_contact_home_phone, u.sec_contact_mobile_phone, u.sec_contact_mail, u.sec_contact_relationship ]
    end
  end
end

get '/admin/users/?' do
  @users = User.find(:all, :attributes => admin_user_attributes)

  session["users"] = @users.map(&:uid)
  erb :admin_users
end

post '/admin/users/?' do
  @filter = params[:filter]
  @users = User.search_users(:filter => @filter, :attributes => admin_user_attributes)
  @users.sort!{ |a,b| a.uid <=> b.uid }

  session["users"] = @users.map(&:uid)
  erb :admin_users
end

get '/admin/user/:uid/?' do |uid|
  @user = User.find(uid) rescue nil
  pass if @user.nil?
  erb :admin_user
end

['/admin/subscriptions/?', '/admin/subscriptions/:year/?'].each do |path|
  get path do
    @years = params[:year].blank? ? Date.today.next_year.year.downto(2010).to_a : [params[:year].to_i]
    @subscriptions = Subscription.count_by_years_and_states
    erb :admin_subscriptions
  end
end

get '/admin/subscriptions/:year/:state/?' do |year,state|
  @year, @state = year.to_i, state
  @subscriptions = Subscription.where(:year => @year, :state => @state).sort(:created_at.desc).all
  erb "admin_subscriptions_#{@state}".to_sym
end

post '/admin/subscriptions/?' do
  puts params['subscriptions'].inspect
  params['subscriptions'].select{|s| s['update'] == 'on'}.each do |data|
    s = Subscription.find data['id']
    unless s.nil? || s.deleted?
      case data['event']
        when 'pay';     s.pay(:user_id => current_user_id,
                              :type => data['payment']['type'],
                              :amount => data['payment']['amount'].to_i,
                              :date => (Date.strptime(data['payment']['date'], '%d/%m/%Y') rescue Date.today),
                              :comment => data['payment']['comment'])\
                        and s.save
        when 'key_in';  s.key_in(:user_id => current_user_id)\
                        and s.save
        when 'deliver'; s.deliver(:user_id => current_user_id)\
                        and s.save
      end
    end
  end
  redirect '/admin/subscriptions'
end

get '/admin/stats/?' do
  @users = User.find(:all)
  erb :admin_stats
end

get '/admin/stats/data/ffck_category_repartition.json' do
  content_type 'application/json', :charset => 'utf-8'
  users = User.find(:all, :attributes => ['cn','ffckCategory']).map(&:ffck_category)
  categories = users.group_by{|u| u.split(' ').first}.map{|k,v| [k,v.size]}
  categories.sort!{|a,b| ffck_categories.index(a.first) <=> ffck_categories.index(b.first)}
  rows = categories.map{|k,v| {:c => [{:v => k},{:v => v}]}}
  {:cols => [{:id => 'cat', :label => 'Catégorie', :type => 'string'},
             {:id => 'nb', :label => 'Nombre', :type => 'number'}],
   :rows => rows }.to_json
end

get '/admin/stats/data/age_repartition.json' do
  content_type 'application/json', :charset => 'utf-8'
  users = User.find(:all, :attributes => ['cn','birthDate']).map(&:age)
  ages = users.group_by{|u| u}.map{|k,v| [k,v.size]}.sort
  rows = ages.map{|k,v| {:c => [{:v => k},{:v => v}]}}
  {:cols => [{:id => 'age', :label => 'Age', :type => 'number'},
             {:id => 'nb', :label => 'Nombre', :type => 'number'}],
   :rows => rows }.to_json
end

# return the ldap attrs needed for listing users
def admin_user_attributes()
  %w(uid cn sn gn gender birthDate ffckCategory ffckNumber postalCode l)
end

