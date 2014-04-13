json.array!(@schools) do |school|
  json.extract! school, :id, :name, :ip_range, :student_remote_access_allowed
  json.url school_url(school, format: :json)
end
