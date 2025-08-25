class CheckInsController < ApplicationController
  before_action :set_attendee, only: [:show, :create]
  
  def show
    if @attendee.nil?
      render :invalid_qr, status: :not_found
      return
    end
    
    @event = @attendee.event
    @check_in = @attendee.check_in || @attendee.build_check_in
    
    if @attendee.checked_in?
      @already_checked_in = true
    end
  end
  
  def create
    if @attendee.nil?
      render json: { error: 'Invalid QR code' }, status: :not_found
      return
    end
    
    @event = @attendee.event
    
    if @attendee.checked_in?
      render json: { 
        success: false, 
        message: 'Already checked in', 
        checked_in_at: @attendee.check_in_time 
      }
      return
    end
    
    begin
      @check_in = CheckIn.check_in_attendee(@attendee, method: 'qr_code')
      
      render json: {
        success: true,
        message: 'Successfully checked in!',
        attendee: {
          name: @attendee.full_name,
          email: @attendee.email,
          checked_in_at: @check_in.checked_in_at
        },
        event: {
          name: @event.name,
          date: @event.date
        }
      }
    rescue StandardError => e
      render json: { 
        success: false, 
        message: 'Check-in failed. Please try manual check-in.' 
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_attendee
    @attendee = Attendee.find_by(qr_code_token: params[:token])
  end
end