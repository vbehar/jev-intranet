# rake tasks for updating the ffck_category field of the users each year

namespace :users do

  desc "Update the ffck_category"
  task :update_ffck_category do
    User.all.each do |user|
      category = user.calculate_ffck_category
      if category != user.ffck_category
        user.ffck_category = category
        user.save
      end
    end
  end

end

