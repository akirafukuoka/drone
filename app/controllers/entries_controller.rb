class EntriesController < ApplicationController
  before_action :check_oauth
  before_action :set_entry, only: [:show, :edit, :update, :destroy, :share]

  before_filter :admin_authorize

  # GET /entries
  # GET /entries.json
  def index
    @entries = Entry.where({oauth_id: @oauth.id}).order("id DESC").page(params[:page])
  end

  # GET /entries/timer
  # GET /entries/timer.json
  def timer
    @entries = Entry.where({oauth_id: @oauth.id}).where.not(:post_hour=>nil, :post_min=>nil).order("post_hour ASC, post_min ASC").page(params[:page])
  end

  # GET /entries/schedule
  # GET /entries/schedule.json
  def schedule
    oauth = @oauth

    old_entry_id = nil
    if oauth.entries.size > 1 && oauth.latest_post.present?
      old_entry_id = oauth.latest_post.entry_id
    end

    ran = 0
    if oauth.latest_post.present?
      latest_entry = Entry.find(oauth.latest_post.entry_id)
      if latest_entry.present?
        ran = latest_entry.ran
      end
    end
    if Entry.where( :oauth_id=>oauth.id, :publish=>true, :post_hour=>nil, :post_min=>nil).where("ran > #{ran}").where.not(:id=>old_entry_id).count == 0
      if oauth.random == true
      else
        ran = 0
      end
    end

    order_str = "ran ASC"
    #@entries = Entry.where( :oauth_id=>oauth.id, :publish=>true, :post_hour=>nil, :post_min=>nil).where("ran >= #{ran}").where.not(:id=>old_entry_id).order(order_str).page(params[:page])

    now = DateTime.now
    now_date = Date.today
    time = oauth.next_time(now.hour, (now.min / 10).floor * 10, now_date.wday)
    p time
    hour = time[0]
    min = time[1]
    wday = time[2]

    @schedule_hour = hour
    @schedule_min = min
    @schedule_wday = wday

    @entries = []
    @entry_times = []
    if oauth.has_time
      for i in 0..24
        if Entry.where(:oauth_id=>oauth.id, :publish=>true, :post_hour=>hour, :post_min=>min).where.not(:id=>old_entry_id).count > 0
          entry = Entry.where(:oauth_id=>oauth.id, :publish=>true, :post_hour=>hour, :post_min=>min).where.not(:id=>old_entry_id).order(order_str).first
        else
          entry = Entry.where( :oauth_id=>oauth.id, :publish=>true, :post_hour=>nil, :post_min=>nil).where("ran > #{ran}").where.not(:id=>old_entry_id).order(order_str).first
          if entry.present?
            ran = entry.ran
          end
        end

        p "#{hour}:::::::#{min}:::::::#{ran}"
        if entry.present?
          p "#{hour}--------#{min}"
          old_entry_id = entry.id
          @entries.push entry
          @entry_times.push [hour, min, wday]
        end

        if Entry.where( :oauth_id=>oauth.id, :publish=>true, :post_hour=>nil, :post_min=>nil).where("ran > #{ran}").where.not(:id=>old_entry_id).count == 0
          if oauth.random == true
            break
          else
            ran = 0
          end
        end
        time = oauth.next_time(hour, min, wday)
        hour = time[0]
        min = time[1]
        wday = time[2]
=begin
        min += oauth.span_min
        if min >= 60
          hour = hour + (min / 60).round
          min = min % 60
        end
        hour = hour % 24
=end
      end
      p @entry_times
    end

    @timer_entries = Entry.where( :oauth_id=>oauth.id, :publish=>true).where.not(:post_hour=>nil, :post_min=>nil).order(order_str)




  end

  # GET /entries/closed
  # GET /entries/closed.json
  def closed
    @entries = Entry.where({oauth_id: @oauth.id}).where(:publish=>false).order("id DESC").page(params[:page])
  end

  # GET /entries/tags
  # GET /entries/tags.json
  def tags
    @tags = Entry.where({oauth_id: @oauth.id}).tag_counts_on(:tags)
  end
  # GET /entries/tags/:tag
  # GET /entries/tags/:tag.json
  def tag
    @entries = Entry.where({oauth_id: @oauth.id}).tagged_with(params[:tag]).order("id DESC").page(params[:page])
  end

    # GET /entries/search
  # GET /entries/search.json
  def search
    @keyword = ""
    if params[:keyword].present?
      @keyword = params[:keyword]
      p @keyword
      @entries = Entry.where({oauth_id: @oauth.id}).order("id DESC").search(:description_cont => @keyword).result.page(params[:page])
    else
      @entries = []
    end
  end


  # GET /entries/1
  # GET /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    @entry = Entry.new

    @entry.description = params[:description] if params[:description].present?
    @entry.url = params[:url] if params[:url].present?
    @entry.tag_list = params[:tag_list] if params[:tag_list].present?
    @entry.post_hour = params[:post_hour] if params[:post_hour].present?
    @entry.post_min = params[:post_min] if params[:post_min].present?
    @entry.publish = params[:publish] if params[:publish].present?

  end

  # GET /entries/1/edit
  def edit
  end

  # POST /entries
  # POST /entries.json
  def create
    @entry = Entry.new(entry_params)
    @entry.oauth_id = @oauth.id
    @entry.tag_list = params[:tag_list]
    @entry.posted_at = DateTime.now
    if @oauth.random == true
      @entry.ran = rand(@oauth.entries.count) + 1
    else
      @entry.ran = @oauth.entries.count + 1
    end
    if @entry.post_hour.present? || @entry.post_min.present?
      @entry.ran = 0
    end
    if params[:image_url].present?
        @entry.image = URI.parse(URI.encode(params[:image_url]))
    end

    respond_to do |format|
      if @entry.save
        format.html { redirect_to "/oauths/#{@oauth.id}/entries", notice: 'Entry was successfully created.' }
        format.json { render action: 'show', status: :created, location: @entry }
      else
        format.html { render action: 'new' }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entries/1
  # PATCH/PUT /entries/1.json
  def update
    @entry.tag_list = params[:tag_list]
    if params[:image_delete].present?
      @entry.image = nil
    end
    if params[:image_url].present?
        @entry.image = URI.parse(URI.encode(params[:image_url]))
    end
    if @entry.post_hour.present? || @entry.post_min.present?
      @entry.ran = 0
    else
      @entry.ran = @entry.id
    end

    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to "/oauths/#{@oauth.id}/entries", notice: 'Entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    Post.destroy_all(:entry_id=>@entry.id)
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to "/oauths/#{@oauth.id}/entries" }
      format.json { head :no_content }
    end
  end

  # GET /entries/1/share
  # GET /entries/1/share.json
  def share
    @entry.share
    respond_to do |format|
      format.html { redirect_to "/oauths/#{@oauth.id}/entries" }
      format.json { head :no_content }
    end
  end

  private
    def check_oauth
      if params["oauth_id"].present? && Oauth.where({id:params["oauth_id"]}).size > 0
        @oauth = Oauth.find(params["oauth_id"])
      else
        redirect_to oauths_path
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      if Entry.where({id: params[:id]}).size > 0
        @entry = Entry.find(params[:id])
      else
        redirect_to "/oauths/#{@oauth.id}/entries"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      params.require(:entry).permit(:oauth_id, :description, :url, :publish, :image, :post_hour, :post_min, :ran)
    end
end
