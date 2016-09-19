class AddMobileAppToMobileAppScreens < ActiveRecord::Migration
  def change
    add_reference :mobile_app_screens, :mobile_app, index: true, foreign_key: true
  end
end
