Rails.application.config.middleware.use OmniAuth::Builder do

  provider :twitter,
    ENV["TWITTER_KEY"],
    ENV["TWITTER_KEY_SECRET"],
    display: 'popup'

  provider :facebook,
    ENV["FACEBOOK_KEY"],
    ENV["FACEBOOK_SECRET"],
    :scope => 'email,publish_stream', :display => 'popup'

end