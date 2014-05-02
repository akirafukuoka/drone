class Post < ActiveRecord::Base
  belongs_to :oauth
  belongs_to :entry
  has_many :retweets

  def posted_url
    url = ''
    if self.posted_id.present?
      url = "http://twitter.com/#{self.oauth.name}/status/#{self.posted_id}"
    end

    url
  end
end
