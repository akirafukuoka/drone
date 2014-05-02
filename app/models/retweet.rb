class Retweet < ActiveRecord::Base
  belongs_to :oauth
  belongs_to :post
end
