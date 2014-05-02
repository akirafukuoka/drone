class SessionsController < ApplicationController

  before_filter :admin_authorize

  def create
    auth = request.env["omniauth.auth"]
    oauth = Oauth.find(:first, :conditions => {:provider=>auth.provider, :uid=>auth.uid })

    if auth.provider=="twitter"

      if auth.provider=="facebook"
        user_name = auth.extra.raw_info.name
        user_image = auth.info.image
      else
        user_name = auth.extra.raw_info.screen_name
        user_image = auth.extra.raw_info.profile_image_url
      end

      p auth.credentials

      unless oauth
        oauth = Oauth.create(:provider=>auth.provider, :uid=>auth.uid, :token=>auth.credentials.token, :token_secret=>auth.credentials.secret , :token_expires_at=>auth.credentials.expires_at, :name=>user_name, :image=>user_image )
      else
        oauth.update_attributes(:provider=>auth.provider, :uid=>auth.uid, :token=>auth.credentials.token, :token_secret=>auth.credentials.secret , :token_expires_at=>auth.credentials.expires_at, :name=>user_name, :image=>user_image )
      end


      p auth
      @oauth = oauth

      redirect_to oauths_path, :notice => "Signed In"

    else
      redirect_to root_path
    end

  end

  def destroy
    redirect_to root_path, :notice => "Signed Out"
  end
end
