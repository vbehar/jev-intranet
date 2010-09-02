# rake tasks for initializing the subscriptions for users

namespace :users do

  desc "Initialize the subscriptions for 2010"
  task :init_subscriptions do
    User.all.each do |u|
      unless Subscription.where(:user_id => u.uid, :year => 2010).exist?
        s = Subscription.new
        s.user_id = u.uid
        s.year = 2010
        s.medical_certificate_type = u.medical_certificate_type
        s.medical_certificate_date = u.medical_certificate_date
        s.created_at = u.ffck_number_date
        s.state = 'sent'
        s.save unless s.created_at.nil?
      end
    end
  end

end

