json.array!(@asientos) do |asiento|
  json.extract! asiento, :id
  json.url asiento_url(asiento, format: :json)
end
