json.array!(@oauths) do |oauth|
  json.extract! oauth, :id, :provider, :token, :token_secret, :token_expires_at, :uid, :name, :image, :publish
  json.url oauth_url(oauth, format: :json)
end
