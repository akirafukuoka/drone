class OauthsController < ApplicationController
  before_action :set_oauth, only: [:show, :edit, :update, :destroy]

  before_filter :admin_authorize

  # GET /oauths
  # GET /oauths.json
  def index
    @oauths = Oauth.order("id DESC").all
  end

  # GET /oauths/1
  # GET /oauths/1.json
  def show
=begin
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key  = ENV["TWITTER_KEY"]
      config.consumer_secret  = ENV["TWITTER_KEY_SECRET"]
      config.oauth_token = @oauth.token
      config.oauth_token_secret = @oauth.token_secret
    end

    require 'pp'

    results = twitter_client.retweets_of_me()
    results.shuffle!
    p results
    results.each do |result|
      p result[:text]
      p result[:user][:id]
      p result[:user][:id_str]
      p result[:user][:screen_name]
    end
=end
    p "----------------------"
    p @oauth.latest_post
    p @oauth.latest_post_has_ran
  end

  # GET /oauths/new
  def new
    @oauth = Oauth.new
  end

  # GET /oauths/1/edit
  def edit
  end

  # POST /oauths
  # POST /oauths.json
  def create
    @oauth = Oauth.new(oauth_params)

    #Coop.delete_all("oauth_id=#{@oauth.id}")
    if params[:coops].present?
      params[:coops].each do |coop_id|
        Coop.find_or_create_by(:oauth_id=>@oauth.id,:coop_oauth_id=>coop_id)
      end
    end
    if params[:week_str].present?
      @oauth.week = params[:week_str].to_s
    end
    if params[:time_str].present?
      @oauth.time = params[:time_str].to_s
    end

    respond_to do |format|
      if @oauth.save
        format.html { redirect_to @oauth, notice: 'Oauth was successfully created.' }
        format.json { render action: 'show', status: :created, location: @oauth }
      else
        format.html { render action: 'new' }
        format.json { render json: @oauth.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /oauths/1
  # PATCH/PUT /oauths/1.json
  def update
    old_r = @oauth.random
    Coop.delete_all("oauth_id=#{@oauth.id}")
    if params[:coops].present?
      params[:coops].each do |coop_id|
        Coop.find_or_create_by(:oauth_id=>@oauth.id,:coop_oauth_id=>coop_id)
      end
    end
    if params[:week_str].present?
      p "-------------------------------"
      p params[:week_str]
      @oauth.week = params[:week_str].to_s
    end
    if params[:time_str].present?
      @oauth.time = params[:time_str].to_s
    end
    respond_to do |format|
      if @oauth.update(oauth_params)
        format.html { redirect_to "/oauths/#{@oauth.id}/entries", notice: 'Oauth was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @oauth.errors, status: :unprocessable_entity }
      end
    end
    if @oauth.random !=old_r
      @oauth.shuffle
    end
  end

  # DELETE /oauths/1
  # DELETE /oauths/1.json
  def destroy
    @oauth.destroy
    respond_to do |format|
      format.html { redirect_to oauths_url }
      format.json { head :no_content }
    end
  end

  # GET /oauths/autoposts
  def autoposts
    Oauth.autoposts
    redirect_to oauths_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oauth
      @oauth = Oauth.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def oauth_params
      params.require(:oauth).permit(:provider, :token, :token_secret, :token_expires_at, :uid, :name, :image, :publish, :frequency, :base_hour, :base_min, :random, :auto_follow, :auto_retweet, :week, :time, :bookmarklet)
    end
end
