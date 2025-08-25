class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :authenticate_user!
  before_action :set_current_time
  
  def health
    render json: { status: 'ok', timestamp: Time.current }
  end
  
  private
  
  def authenticate_user!
    # Check for JWT token in params, headers, or session
    token = extract_jwt_token
    
    if token.present?
      payload = JwtAuthService.decode(token)
      
      if payload
        @current_user = User.from_jwt_payload(payload)
        @current_user.update(last_login_at: Time.current)
        session[:user_id] = @current_user.id
        return
      end
    end
    
    # Check session for existing login
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
      return if @current_user
    end
    
    # Redirect to main app login if no valid authentication
    redirect_to main_app_login_url
  end
  
  def current_user
    @current_user
  end
  
  def extract_jwt_token
    # From URL parameter (main app redirect)
    params[:token] ||
    # From Authorization header
    request.headers['Authorization']&.gsub(/^Bearer /, '') ||
    # From session
    session[:jwt_token]
  end
  
  def main_app_login_url
    # Configure this to point to your main app
    "https://app.blackbirdrsvp.com/login?return_to=#{CGI.escape(request.original_url)}"
  end
  
  def set_current_time
    @current_time = Time.current
  end
  
  def handle_csv_import_errors
    yield
  rescue CSV::MalformedCSVError => e
    flash[:alert] = "Invalid CSV file format: #{e.message}"
    redirect_back(fallback_location: root_path)
  rescue StandardError => e
    flash[:alert] = "Import failed: #{e.message}"
    redirect_back(fallback_location: root_path)
  end
  
  helper_method :current_user
end