require 'fastercsv'

get '/admin' do
  erb :admin_index
end

get '/admin/about' do
  "Environment : " + ( options.environment.to_s rescue "undefined" )
end

get '/admin/users.csv' do
  expires 0, :private, :no_cache, :no_store
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

get '/admin/users' do
  @users = User.find(:all, :attributes => admin_user_attributes)

  session["users"] = @users.collect{|u| u.uid}
  erb :admin_users
end

post '/admin/users' do
  @filter = params[:filter]
  @users = User.search_users(:filter => @filter, :attributes => admin_user_attributes)
  @users.sort!{ |a,b| a.uid <=> b.uid }

  session["users"] = @users.collect{|u| u.uid}
  erb :admin_users
end

get '/admin/user/:uid' do |uid|
  @user = User.find(uid)
  erb :admin_user
end

get '/admin/stats' do
  @users = User.find(:all)
  erb :admin_stats
end

get '/admin/stats/graphs' do
  erb :admin_stats_graphs
end

get '/admin/stats/data/ffck_category_repartition.json' do
  content_type 'application/json', :charset => 'utf-8'
  users = User.find(:all, :attributes => ['cn','ffckCategory']).collect{|u| u.ffck_category.to_s}
  categories = users.group_by{|u| u.split(' ').first}.collect{|k,v| [k,v.size]}
  categories.sort!{|a,b| ffck_categories.index(a.first) <=> ffck_categories.index(b.first)}
  rows = categories.map{|k,v| {:c => [{:v => k},{:v => v}]}}
  {:cols => [{:id => 'cat', :label => 'Catégorie', :type => 'string'},
             {:id => 'nb', :label => 'Nombre', :type => 'number'}],
   :rows => rows }.to_json
end

# return the ldap attrs needed for listing users
def admin_user_attributes()
  %w(uid cn sn gn gender birthDate ffckCategory ffckNumber postalCode l)
end

