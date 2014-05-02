class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_admin_authorize

  def admin_authorize
    if session[:logedin] == true
    else
      redirect_to "/login"
    end
  end
  def check_admin_authorize
    if session[:logedin] == true
      @is_admin = true
    else
      @is_admin = false
    end
  end

end
