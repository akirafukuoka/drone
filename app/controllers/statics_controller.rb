class StaticsController < ApplicationController

  before_filter :admin_authorize, :except=>[ 'login', 'login_session' ]

  def index
  end

  def login

    if session[:logedin] == true
      redirect_to root_path
    end
  end

  def logout
    flash[:notice] = "Logoutしました"
    session[:logedin]=false
    redirect_to "/login"
  end

  def login_session

    if params[:id]==ENV["LOGIN_ID"] && params[:password]==ENV["LOGIN_PASSWORD"]
      flash[:notice] = "Loginしました"
      session[:logedin] = true
      redirect_to root_path
    else
      flash[:notice] = "Loginに失敗しました"
      redirect_to "/login"
    end
  end
end
