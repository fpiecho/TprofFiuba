class Version < ActiveRecord::Base
	belongs_to :mobile_app

	validates :description, presence: { message: " is required" }
end
