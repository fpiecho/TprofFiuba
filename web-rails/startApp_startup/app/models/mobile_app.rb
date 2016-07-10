class MobileApp < ActiveRecord::Base
	belongs_to :user

	validates :title, presence: { message: "Title is required" }

	validate :user_app_title_used, :on => [ :create, :update ]
	validate :freeze_title, :on => :update


	def user_app_title_used
		@user = User.find(self.user_id)
		@mobile_apps = @user.mobile_apps.select{|a| a.title == self.title && a.id != self.id}
		if (@mobile_apps.any?)
      		errors.add(:title_already_used, "")
    	end
    end

    def freeze_title
    	errors.add(:title, " cannot be changed") if self.title_changed?
  	end

end
