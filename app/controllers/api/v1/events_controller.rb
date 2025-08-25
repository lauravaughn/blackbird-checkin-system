class Api::V1::EventsController < ApplicationController
  before_action :set_event
  
  def stats
    @stats = {
      total_attendees: @event.total_attendees,
      checked_in: @event.checked_in_count,
      pending: @event.pending_check_ins,
      percentage: @event.check_in_percentage
    }
    
    @recent_check_ins = @event.check_ins
      .joins(:attendee)
      .where(checked_in: true)
      .order(checked_in_at: :desc)
      .limit(10)
      .includes(:attendee)
    
    render json: {
      stats: @stats,
      recent_checkins: @recent_check_ins.map do |check_in|
        {
          id: check_in.id,
          attendee: {
            id: check_in.attendee.id,
            full_name: check_in.attendee.full_name,
            email: check_in.attendee.email
          },
          check_in_method: check_in.check_in_method,
          checked_in_at: check_in.checked_in_at
        }
      end
    }
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Event not found' }, status: :not_found
  end
end