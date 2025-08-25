class ScannerController < ApplicationController
  before_action :set_event
  
  def show
    @stats = {
      total: @event.total_attendees,
      checked_in: @event.checked_in_count,
      pending: @event.pending_check_ins,
      percentage: @event.check_in_percentage
    }
  end
  
  def scan
    token = extract_token_from_url(params[:qr_data])
    
    if token.blank?
      render json: { 
        success: false, 
        message: 'Invalid QR code format' 
      }, status: :bad_request
      return
    end
    
    attendee = Attendee.find_by(qr_code_token: token, event: @event)
    
    if attendee.nil?
      render json: { 
        success: false, 
        message: 'QR code not found for this event' 
      }, status: :not_found
      return
    end
    
    if attendee.checked_in?
      render json: { 
        success: false, 
        message: "#{attendee.full_name} is already checked in",
        attendee: attendee_json(attendee),
        already_checked_in: true
      }
      return
    end
    
    begin
      check_in = CheckIn.check_in_attendee(attendee, method: 'qr_code')
      
      render json: {
        success: true,
        message: "#{attendee.full_name} checked in successfully!",
        attendee: attendee_json(attendee),
        stats: updated_stats
      }
    rescue StandardError => e
      render json: { 
        success: false, 
        message: 'Check-in failed. Please try again.' 
      }, status: :unprocessable_entity
    end
  end
  
  def manual_check_in
    attendee = find_attendee_by_search(params[:search_term])
    
    if attendee.nil?
      render json: { 
        success: false, 
        message: 'Attendee not found' 
      }, status: :not_found
      return
    end
    
    if attendee.checked_in?
      render json: { 
        success: false, 
        message: "#{attendee.full_name} is already checked in",
        attendee: attendee_json(attendee),
        already_checked_in: true
      }
      return
    end
    
    begin
      check_in = CheckIn.manual_check_in(attendee, current_user)
      
      render json: {
        success: true,
        message: "#{attendee.full_name} manually checked in!",
        attendee: attendee_json(attendee),
        stats: updated_stats
      }
    rescue StandardError => e
      render json: { 
        success: false, 
        message: 'Manual check-in failed. Please try again.' 
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_event
    @event = Event.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Event not found' }, status: :not_found
  end
  
  def extract_token_from_url(qr_data)
    # Extract token from URL like "https://your-app.com/check_in/TOKEN"
    return qr_data if qr_data.length == 43 # Direct token
    
    uri = URI.parse(qr_data)
    path_parts = uri.path.split('/')
    token_index = path_parts.index('check_in')
    
    if token_index && path_parts[token_index + 1]
      path_parts[token_index + 1]
    else
      nil
    end
  rescue URI::InvalidURIError
    nil
  end
  
  def find_attendee_by_search(search_term)
    return nil if search_term.blank?
    
    search_term = search_term.strip.downcase
    
    # Try exact email match first
    attendee = @event.attendees.find_by('LOWER(email) = ?', search_term)
    return attendee if attendee
    
    # Try name search
    @event.attendees.where(
      "LOWER(first_name || ' ' || last_name) LIKE ? OR LOWER(email) LIKE ?",
      "%#{search_term}%", "%#{search_term}%"
    ).first
  end
  
  def attendee_json(attendee)
    {
      id: attendee.id,
      name: attendee.full_name,
      email: attendee.email,
      company: attendee.company,
      checked_in: attendee.checked_in?,
      checked_in_at: attendee.check_in_time&.strftime('%I:%M %p')
    }
  end
  
  def updated_stats
    @event.reload
    {
      total: @event.total_attendees,
      checked_in: @event.checked_in_count,
      pending: @event.pending_check_ins,
      percentage: @event.check_in_percentage
    }
  end
  
  def current_user
    # Placeholder for authentication
    # In a real app, this would return the current authenticated user
    nil
  end
end