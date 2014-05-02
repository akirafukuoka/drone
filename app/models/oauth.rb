class Oauth < ActiveRecord::Base
  has_many :entries
  has_many :posts
  has_many :coops
  has_many :retweets
  has_many :follows
  scope :published, where(:publish=>true)

  def bookmarklet_to_code
    require 'uri'

    return "javascript:(function(d){function l(){(function($){#{URI::encode(self.bookmarklet)}})(jQuery)}if(typeof jQuery=='undefined'){var j=d.createElement('script');j.type='text/javascript';j.src='https://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.address';d.body.appendChild(j);j.onload=l}else{l()}})(document);"
  end

  def entry_count
    Entry.where(:oauth_id=>self.id).count
  end

  def latest_post
    Post.where(:oauth_id=>self.id).order("created_at DESC").first
  end
  def latest_post_has_ran
    Post.includes(:entry).where( Post.arel_table[:oauth_id].eq(self.id).and(Entry.arel_table[:ran].not_eq(0)) ).order("posts.created_at DESC").first
  end

  def cooped (from_oauth)
    if Coop.where(:oauth_id=>from_oauth.id, :coop_oauth_id=>self.id).count > 0
      true
    else
      false
    end
  end

  def span_min
    oauth = self

    span =
    case oauth.frequency
      when "day"; 60*24
      when "12_hour";  60*12
      when "6_hour";  60*6
      when "3_hour";  60*3
      when "2_hour";  60*2
      when "hour";  60*1
      when "30_min"; 30
    else 10
    end

    return span
  end

  #基底時間を分で返す 2:30→60*2+30 = 150
  def minimum_min
    oauth = self

    (oauth.base_hour*60+oauth.base_min) % oauth.span_min
  end

  #基底時間を配列で返す 2:30→60*2+30 = 150
  def minimum_time
    oauth = self
    minimum = oauth.minimum_min

    [(minimum/60).floor, minimum%60]
  end

  #指定の時刻が活動時刻か返す
  def is_turn (hour, min)
    oauth = self
=begin
    if oauth.minimum_min == (hour*60+min) % oauth.span_min
      true
    else
      false
    end
=end
    if oauth.time[hour*6+(min/10).floor] == "1"
      true
    else
      false
    end
  end

  def is_turn_w (hour, min, week)
    oauth = self
=begin
    if oauth.minimum_min == (hour*60+min) % oauth.span_min
      true
    else
      false
    end
=end
    if oauth.week[week] == "1" && oauth.time[hour*6+(min/10).floor] == "1"
      true
    else
      false
    end
  end

  #weekがそもそも設定されているか確認
  def has_week
    oauth = self
    if oauth.week != "0000000"
      true
    else
      false
    end
  end

  #timeがそもそも設定されているか確認
  def has_time
    oauth = self
    if oauth.time != "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      true
    else
      false
    end
  end

  #次の活動時刻を返す（xx, yy）
  def next_time(hour, min, week)
    oauth = self
    time = []

    if oauth.has_time && oauth.has_week
      now_hour = hour
      now_min = (min/10).floor
      now_week = week

      num = nil
      change_day = true
      for i in 0..143
        if oauth.time[i]=="1"
          if num == nil
            num = i
          end
          if i>now_hour*6+now_min
            num = i
            change_day = false
            break
          end
        end
      end

      if change_day
        next_weekday = nil
        for i in 0..6
          if oauth.week[i]=="1"
            if next_weekday == nil
              next_weekday = i
            end
            if i>now_week
              next_weekday = i
              break
            end
          end
        end
      else
        next_weekday = now_week
      end

      [(num/6).floor, (num%6)*10, next_weekday]
    else
      [nil, nil, nil]
    end

=begin
    now = DateTime.now
    now_hour = now.hour
    now_min = now.min / 10 * 10

    time = oauth.minimum_min
    while time < 60*24
      if time > now_hour*60+now_min
        break
      end
      time += oauth.span_min
    end

    [(time/60).floor % 24, time%60]
=end
  end

  def shuffle
    oauth = self
    if ENV['RAILS_ENV'] =="production"
      order_str ="random()"
    else
      order_str = "RAND()"
    end
    if oauth.random == true
      entries = Entry.where(:oauth_id=>oauth.id).order(order_str)
    else
      entries = Entry.where(:oauth_id=>oauth.id).order("id ASC")
    end

    ran = 1
    entries.each do |entry|
      ran2 = ran
      if entry.post_hour.present? || entry.post_min.present?
        ran2 = 0
      elsif oauth.random==false
        ran2 = entry.id
      end
      entry.update_attributes!( :ran=>ran2 )
      ran += 1
    end
  end

  def autopost (hour, min)
    oauth = self
    if oauth.publish && oauth.has_time
      p "-------------autopost #{oauth.id}---------------"

      old_entry_id = nil
      if oauth.entries.size > 1 && oauth.latest_post_has_ran.present?
        old_entry_id = oauth.latest_post_has_ran.entry_id
      end

      ran = 0
      posted_at_ask = "posted_at ASC"
      id_at_ask = "id"
      if oauth.random
        if ENV['RAILS_ENV'] =="production"
          order_str ="random()"
        else
          order_str = "RAND()"
        end

        if oauth.latest_post_has_ran.present?
          latest_entry = Entry.find(oauth.latest_post_has_ran.entry_id)
          if latest_entry.present?
            ran = latest_entry.ran
          end
          if Entry.where( :oauth_id=>oauth.id, :publish=>true, :post_hour=>nil, :post_min=>nil).where("ran > #{latest_entry.ran}").where.not(:id=>old_entry_id).count == 0
            oauth.shuffle
            ran = 0
          end
        end
        order_str = "ran ASC"
      else
        order_str = "ran ASC"
        #order_str = posted_at_ask
      end

      same_time_count = Entry.where(:oauth_id=>oauth.id, :publish=>true, :post_hour=>hour, :post_min=>min).count
      if same_time_count > 0
        #同時刻設定のEntryがあった場合
        #entry = Entry.where(:oauth_id=>oauth.id, :publish=>true, :post_hour=>hour, :post_min=>min).where.not(:id=>old_entry_id).order(order_str).first
        entry = Entry.where(:oauth_id=>oauth.id, :publish=>true, :post_hour=>hour, :post_min=>min).where.not(:id=>old_entry_id).order(order_str).first
      else
        #entry = Entry.where(:oauth_id=>oauth.id, :publish=>true, :post_hour=>nil, :post_min=>nil).not(:id=>old_entry_id).order(order_str).first
        #entry = Entry.where(  :oauth_id=>oauth.id, :publish=>true, :post_hour=>nil, :post_min=>nil).where.not(:id=>old_entry_id).order(order_str).first
        entry = Entry.where( :oauth_id=>oauth.id, :publish=>true, :post_hour=>nil, :post_min=>nil).where("ran > #{ran}").where.not(:id=>old_entry_id).order(order_str).first
      end
      if entry.present?
        entry.share
      else
      end
    end
  end

  def self.autoposts
    now = DateTime.now
    date = Date.today
    hour = now.hour
    min = now.min / 10 * 10
    oauths = Oauth.all
    oauths.each do |oauth|
      p "-----------check:#{oauth.id}--------------"

=begin
      if oauth.frequency == "day"
        if oauth.base_hour == hour && oauth.base_min == min
          #1日ごとポストの設定の場合
          oauth.autopost(hour, min)
        end
      elsif oauth.frequency == "hour"
        if oauth.base_min == min
          #一時間ごとポストの設定の場合
          oauth.autopost(hour, min)
        end
      else
        oauth.autopost(hour, min)
      end
=end

      if oauth.is_turn_w(hour, min, date.wday)
        oauth.autopost(hour, min)
      end

      oauth.retweet_coops_tweet()
      oauth.follow_from_mentions()
      oauth.follow_from_retweeter()

    end
  end

  def retweet_coops_tweet
    oauth = self

    if oauth.auto_retweet
      p "retweet_coops_tweet #{oauth.id}"
      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key  = ENV["TWITTER_KEY"]
        config.consumer_secret  = ENV["TWITTER_KEY_SECRET"]
        config.oauth_token = oauth.token
        config.oauth_token_secret = oauth.token_secret
      end

      begin
        if ENV['RAILS_ENV'] =="production"
          order_str ="random()"
        else
          order_str = "RAND()"
        end
        #oauth.coops.each do |coop|
        coop = oauth.coops.order(order_str).first
        if rand(100) < 5
          coop_oauth = Oauth.find(coop.coop_oauth_id)
          if coop_oauth.present?
            post = Post.where(:oauth_id=>coop_oauth.id, :error=>false).order(order_str).first
            posts = Post.where(:oauth_id=>coop_oauth.id, :error=>false).order(order_str).limit(100)
            posts.each do |post|
              if post.retweets.where(:oauth_id=>oauth.id).count == 0
                result = twitter_client.retweet(post.posted_id)
                Retweet.find_or_create_by(:oauth_id=>oauth.id, :post_id=>post.id)
                break
              end
            end
          end
        end
        #end
      rescue => ex
      end

    end
  end

  def follow_from_mentions

    oauth = self
    if oauth.auto_follow
      p "follow_from_mentions #{oauth.id}"
      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key  = ENV["TWITTER_KEY"]
        config.consumer_secret  = ENV["TWITTER_KEY_SECRET"]
        config.oauth_token = oauth.token
        config.oauth_token_secret = oauth.token_secret
      end

      begin
        results = twitter_client.mentions_timeline()
        #p results
        results.each do |result|
          #p result[:text]
          #p result[:user][:id]
          #p result[:user][:id_str]
          p result[:user][:screen_name]
          _follow(oauth, result[:user][:screen_name])
        end
      rescue => ex
        p ex
      end

    end

    return
  end

  def follow_from_retweeter

    oauth = self
    if oauth.auto_follow
      p "follow_from_retweeter #{self.id}"
      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key  = ENV["TWITTER_KEY"]
        config.consumer_secret  = ENV["TWITTER_KEY_SECRET"]
        config.oauth_token = oauth.token
        config.oauth_token_secret = oauth.token_secret
      end

=begin
      p  oauth.latest_post
      p oauth.latest_post.posted_id
      if oauth.latest_post.posted_id.present?
        begin
          p "begin"
          users = twitter_client.retweeters_of(oauth.latest_post.posted_id)
          p users
          i = 0
          users.each do |twitter_user|
            if i<100
              p twitter_user
              p twitter_user['screen_name']
              followed = _follow(oauth, twitter_user['screen_name'])
              if followed
                i -= 1
              end
            end
            i += 1
          end
          #p users
        rescue => ex
          p ex
        end
=end

      begin
        results = twitter_client.retweets_of_me()
        k = 0
        results.shuffle!
        p results
        results.each do |result|
          if k < 3
            users = twitter_client.retweeters_of(result['id'])
            p users
            i = 0
            users.each do |twitter_user|
              if i<100
                p twitter_user
                p twitter_user['screen_name']
                followed = _follow(oauth, twitter_user['screen_name'])
                if followed
                  i -= 1
                end
              end
              i += 1
            end
          end
          k += 1
        end
      rescue => ex
        p ex
      end

    end

    return
  end

  private
  def _follow (oauth, twitter_id)

    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key  = ENV["TWITTER_KEY"]
      config.consumer_secret  = ENV["TWITTER_KEY_SECRET"]
      config.oauth_token = oauth.token
      config.oauth_token_secret = oauth.token_secret
    end

    p "_follow"
    follows = Follow.where(:oauth_id=>oauth.id, :twitter_id=>twitter_id.to_s)
    followed = false
    if follows.count == 0
      twitter_client.follow(twitter_id.to_s)
      Follow.find_or_create_by(:oauth_id=>oauth.id, :twitter_id=>twitter_id.to_s)
      p "_follow__3"
    else
      followed = true
    end
    followed
  end

end
