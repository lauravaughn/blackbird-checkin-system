class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login]
  
  def login
    # This page is shown if user is not authenticated
    # In practice, they'll usually be redirected here from main app with JWT
  end
  
  def logout
    session[:user_id] = nil
    session[:jwt_token] = nil
    
    # Redirect to main app logout
    redirect_to "https://app.blackbirdrsvp.com/logout"
  end
end