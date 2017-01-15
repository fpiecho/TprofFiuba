class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :message
      t.integer :mobile_app_id
      t.datetime :action_date

      t.timestamps null: false
    end
  end
end
