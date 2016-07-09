class AddUserToMobileApps < ActiveRecord::Migration
  def change
    add_reference :mobile_apps, :user, index: true, foreign_key: true
  end
end
