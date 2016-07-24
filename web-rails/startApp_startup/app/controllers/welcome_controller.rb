class WelcomeController < ApplicationController
  def index
  	if !user_signed_in?
  		redirect_to new_user_session_path
  	else
  		redirect_to mobile_apps_path
  	end
  end
end
