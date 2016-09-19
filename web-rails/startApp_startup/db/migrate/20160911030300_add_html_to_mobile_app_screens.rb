class AddHtmlToMobileAppScreens < ActiveRecord::Migration
  def change
    add_column :mobile_app_screens, :raw_html, :text
    add_column :mobile_app_screens, :editor_html, :text
  end
end
