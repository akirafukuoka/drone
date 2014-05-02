class Entry < ActiveRecord::Base
  belongs_to :oauth
  has_one :oauth
  has_many :posts
  acts_as_taggable_on :tags
  scope :published, where(:publish=>true)
  scope :by_posted, order("posted_at ASC")
  validates :description, presence: true, length: { minimum: 1, maximum: 140 }
  has_attached_file :image,
    :styles => { :thumb => "500x500#" },
    :default_url => "/images/:style/missing.png",
    :storage => :s3,
    :s3_credentials => {
      bucket: ENV["S3_BUCKET_NAME"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      s3_host_name: ENV["S3_HOST_NAME"]
    }
  do_not_validate_attachment_file_type :image

  paginates_per 10

  def latest_post
    Post.where(:entry_id=>self.id).order("created_at DESC").first
  end

  def posted_count
    Post.where(:entry_id=>self.id, :error=>false).count
  end

  def description_all (html_tag)
    twitter_message = self.description
    if twitter_message.length > 90
      twitter_message = "#{twitter_message[0, 90]}..."
    end

    url = ''
    if self.url.present?
      if html_tag
        url = URI.encode(self.url)
        original_url = url
        if url.length > 22
          url = "#{url[0, 22]}..."
        end
        url = " <a href=\"#{original_url}\" target=\"_blank\" class=\"url\">#{url}</a>"
      else
        url = " #{URI.encode(self.url)}"
      end
    end

    tags = ''
    if self.tag_list.present?
      self.tag_list.each do |tag|
        if html_tag
          tag_a = "<a href=\"http://twitter.com/##{tag}\" target=\"_blank\" class=\"tag\">##{tag}</a>"
          tags = "#{tags} #{tag_a}"
        else
          tags = "#{tags} ##{tag}"
        end
      end
    end

    str = "#{twitter_message}#{url}#{tags}"

    if html_tag
      str = str.gsub(/\r\n|\r|\n/, "<br />")
    end

    str
  end

  def share

    oauth = Oauth.find(self.oauth_id)
    if oauth.publish && self.publish

      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key  = ENV["TWITTER_KEY"]
        config.consumer_secret  = ENV["TWITTER_KEY_SECRET"]
        config.oauth_token = oauth.token
        config.oauth_token_secret = oauth.token_secret
      end
      #twitter_client = Twitter::Client.new

      message_all = self.description_all(false)

      require 'uri'
      require 'net/http'
      require 'net/https'

      begin
        if self.image.present?
          encoded_url = URI::encode(self.image.url.to_s)
          uri = URI.parse(encoded_url)
          media = uri.open
          media.instance_eval("def original_filename; '#{File.basename(uri.path)}'; end")
          result = twitter_client.update_with_media(message_all, media)
        else
          result = twitter_client.update(message_all)
        end

        shared_url = ''
        posted_id = ''
        if result.present?
          if oauth.provider=="twitter"
            # twitter
            p "result"
            p result
            shared_url = "https://twitter.com/#{oauth.name}/status/#{result['id']}"
            posted_id = result['id']
          else
            #facebook?
            shared_url = "http://www.facebook.com/#{result['id']}"
            posted_id = result['id']
          end
        end
        p shared_url

        Post.create(:oauth_id => oauth.id, :entry_id => self.id, :posted_id => posted_id, :error=>false)
      rescue => ex
        Post.create(:oauth_id => oauth.id, :entry_id => self.id, :posted_id => '', :error=>true)
      end

      self.update_attributes!( :posted_at=>DateTime.now )

    end



  end
end
