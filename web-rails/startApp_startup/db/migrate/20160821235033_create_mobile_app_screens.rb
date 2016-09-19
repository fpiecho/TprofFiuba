class CreateMobileAppScreens < ActiveRecord::Migration
  def change
    create_table :mobile_app_screens do |t|
      t.string :mobile_app
      t.string :name

      t.timestamps null: false
    end
  end
end
