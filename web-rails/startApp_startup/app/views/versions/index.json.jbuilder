json.array!(@versions) do |version|
  json.extract! version, :id, :description, :mobile_app_id
  json.url version_url(version, format: :json)
end
