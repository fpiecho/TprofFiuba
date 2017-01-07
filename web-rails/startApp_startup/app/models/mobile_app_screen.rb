class MobileAppScreen < ActiveRecord::Base
	belongs_to :mobile_app

	validates :name, presence: { message: " is required" }
end
