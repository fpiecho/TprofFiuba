class MobileAppScreen < ActiveRecord::Base
	belongs_to :mobile_app

	validates :name, presence: { message: "Name is required" }
	validate :user_app_screen_title_used, :on => [ :create, :update ]

	def user_app_screen_title_used
		MobileAppScreen.where(mobile_app: @mobile_app)
		@mobileApp = MobileApp.find(self.mobile_app)
		@mobile_app_screens = @mobileApp.mobile_app_screens.select{|a| a.name == self.name && a.id != self.id}
		if (@mobile_app_screens.any?)
      		errors.add(:name_already_used, "")
    	end
    end

end
