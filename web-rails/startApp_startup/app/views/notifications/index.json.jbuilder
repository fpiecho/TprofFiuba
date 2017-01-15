json.array!(@notifications) do |notification|
  json.extract! notification, :id, :message, :mobile_app_id, :action_date
  json.url notification_url(notification, format: :json)
end
