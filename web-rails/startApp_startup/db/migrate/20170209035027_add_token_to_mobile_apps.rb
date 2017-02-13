class AddTokenToMobileApps < ActiveRecord::Migration
  def change
    add_column :mobile_apps, :token, :string
  end
end
