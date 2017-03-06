class AddWsUrlToMobileAppScreens < ActiveRecord::Migration
  def change
  	add_column :mobile_app_screens, :wsURL, :text
  end
end
