class AddSentToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :sent, :boolean
  end
end
