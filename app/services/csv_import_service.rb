require 'csv'

class CsvImportService
  attr_reader :event, :errors, :imported_count
  
  def initialize(event)
    @event = event
    @errors = []
    @imported_count = 0
  end
  
  def import_attendees(csv_content)
    @imported_count = 0
    @errors = []
    
    # Parse CSV and validate headers
    csv_data = CSV.parse(csv_content, headers: true)
    validate_headers(csv_data.headers)
    
    return 0 if @errors.any?
    
    # Process each row
    csv_data.each_with_index do |row, index|
      process_attendee_row(row, index + 2) # +2 for header row and 0-based index
    end
    
    @imported_count
  end
  
  def success?
    @errors.empty?
  end
  
  private
  
  def validate_headers(headers)
    required_headers = ['email', 'first_name', 'last_name']
    missing_headers = required_headers - headers.map(&:downcase)
    
    if missing_headers.any?
      @errors << "Missing required columns: #{missing_headers.join(', ')}"
    end
  end
  
  def process_attendee_row(row, row_number)
    # Normalize column names
    normalized_row = {}
    row.headers.each do |header|
      normalized_row[header.downcase.strip] = row[header]&.strip
    end
    
    # Validate required fields
    unless valid_email?(normalized_row['email'])
      @errors << "Row #{row_number}: Invalid email address"
      return
    end
    
    if normalized_row['first_name'].blank?
      @errors << "Row #{row_number}: First name is required"
      return
    end
    
    if normalized_row['last_name'].blank?
      @errors << "Row #{row_number}: Last name is required"
      return
    end
    
    # Check for duplicate in this event
    if @event.attendees.exists?(email: normalized_row['email'].downcase)
      @errors << "Row #{row_number}: #{normalized_row['email']} already exists for this event"
      return
    end
    
    # Create attendee
    begin
      attendee = @event.attendees.create!(
        email: normalized_row['email'].downcase,
        first_name: normalized_row['first_name'],
        last_name: normalized_row['last_name'],
        company: normalized_row['company'],
        job_title: normalized_row['job_title'],
        phone: normalized_row['phone'],
        notes: normalized_row['notes']
      )
      
      @imported_count += 1
    rescue ActiveRecord::RecordInvalid => e
      @errors << "Row #{row_number}: #{e.message}"
    rescue StandardError => e
      @errors << "Row #{row_number}: Failed to create attendee - #{e.message}"
    end
  end
  
  def valid_email?(email)
    return false if email.blank?
    
    email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    email =~ email_regex
  end
end