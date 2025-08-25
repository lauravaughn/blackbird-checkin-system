class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :dashboard, :import_attendees]
  
  def index
    @events = Event.all.order(date: :desc)
    @upcoming_events = @events.upcoming
    @past_events = @events.past
  end
  
  def show
    @attendees = @event.attendees.includes(:check_in)
    @stats = {
      total: @event.total_attendees,
      checked_in: @event.checked_in_count,
      pending: @event.pending_check_ins,
      percentage: @event.check_in_percentage
    }
  end
  
  def new
    @event = Event.new
  end
  
  def create
    @event = Event.new(event_params)
    @event.event_code = generate_event_code
    
    if @event.save
      redirect_to @event, notice: 'Event created successfully!'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event updated successfully!'
    else
      render :edit
    end
  end
  
  def destroy
    @event.destroy
    redirect_to events_path, notice: 'Event deleted successfully!'
  end
  
  def dashboard
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
  end
  
  def import_attendees
    handle_csv_import_errors do
      if params[:csv_file].present?
        csv_content = params[:csv_file].read
        imported_count = CsvImportService.new(@event).import_attendees(csv_content)
        
        flash[:notice] = "Successfully imported #{imported_count} attendees!"
      else
        flash[:alert] = "Please select a CSV file to import."
      end
      
      redirect_to @event
    end
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  end
  
  def event_params
    params.require(:event).permit(:name, :description, :date, :venue, :venue_address, :expected_attendees)
  end
  
  def generate_event_code
    loop do
      code = SecureRandom.alphanumeric(8).upcase
      break code unless Event.exists?(event_code: code)
    end
  end
end