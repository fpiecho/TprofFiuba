class AddApptypeToMobileApps < ActiveRecord::Migration
  def change
    add_column :mobile_apps, :apptype, :string
  end
end
