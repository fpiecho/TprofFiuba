json.array!(@mobile_app_screens) do |mobile_app_screen|
  json.extract! mobile_app_screen, :id, :mobile_app, :name
  json.url mobile_app_screen_url(mobile_app_screen, format: :json)
end
