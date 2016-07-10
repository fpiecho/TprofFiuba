class AddPortToMobileApps < ActiveRecord::Migration
  def change
    add_column :mobile_apps, :port, :string
  end
end
