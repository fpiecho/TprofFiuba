class Notification < ActiveRecord::Base
	belongs_to :mobile_app

	validates :message, presence: { message: " is required" }
	validates :action_date, presence: { message: " is required" }
end
