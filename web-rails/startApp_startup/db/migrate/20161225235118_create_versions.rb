class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :description
      t.integer :mobile_app_id

      t.timestamps null: false
    end
  end
end
