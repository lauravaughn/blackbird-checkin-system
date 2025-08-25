# Blackbird RSVP Check-in System

A professional QR code-based check-in system for corporate events, built with Ruby on Rails.

## Features

- **Event Management**: Create and manage events with detailed information
- **CSV Import**: Bulk import attendee lists via CSV upload
- **QR Code Generation**: Automatic QR code creation and email distribution
- **Mobile Scanner**: Mobile-friendly QR code scanner interface
- **Manual Check-in**: Backup check-in option when QR codes don't work
- **Real-time Dashboard**: Live event statistics and check-in monitoring
- **Responsive Design**: Mobile-first design for all screen sizes

## Technology Stack

- **Backend**: Ruby on Rails 7.0
- **Database**: PostgreSQL
- **QR Codes**: rqrcode gem
- **Email**: ActionMailer (configurable with SendGrid)
- **Frontend**: Bootstrap 5, HTML5 QR Code Scanner
- **Styling**: Mobile-first responsive CSS

## Prerequisites

Before setting up the application, ensure you have:

- Ruby 3.0+ installed
- PostgreSQL installed and running
- Node.js and npm/yarn for asset compilation
- Git for version control

## Installation & Setup

1. **Navigate to the project directory:**
   ```bash
   cd blackbird_checkin
   ```

2. **Install Ruby dependencies:**
   ```bash
   bundle install
   ```

3. **Set up the database:**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Install JavaScript dependencies:**
   ```bash
   npm install  # or yarn install
   ```

5. **Start the Rails server:**
   ```bash
   rails server
   ```

6. **Visit the application:**
   Open http://localhost:3000 in your browser

## Usage Guide

### Creating an Event

1. Navigate to the Events page
2. Click "New Event"
3. Fill in event details (name, date, venue)
4. Save the event

### Importing Attendees

1. Prepare a CSV file with columns: email, first_name, last_name, company (optional)
2. Go to your event page
3. Click "Import CSV"
4. Upload your file
5. QR codes will be automatically generated and emailed

### Using the Scanner

1. From the event page, click "Scanner"
2. Allow camera permissions
3. Start the scanner
4. Point camera at QR codes to check in attendees
5. Use manual check-in tab for backup entry

### Monitoring Check-ins

1. Use the Dashboard for real-time statistics
2. View recent check-ins and overall progress
3. Export data for reporting

## CSV Import Format

Your CSV file should have these columns:

```csv
email,first_name,last_name,company,job_title,phone
john.doe@example.com,John,Doe,Acme Corp,Software Engineer,(555) 123-4567
jane.smith@example.com,Jane,Smith,Tech Inc,Marketing Manager,(555) 987-6543
```

**Required columns**: email, first_name, last_name
**Optional columns**: company, job_title, phone

## Configuration

### Email Setup

Configure email settings in `config/environments/production.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.sendgrid.net',
  port: 587,
  domain: 'your-domain.com',
  user_name: ENV['SENDGRID_USERNAME'],
  password: ENV['SENDGRID_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

### Environment Variables

Set these environment variables:

```bash
DATABASE_URL=postgresql://username:password@localhost/blackbird_checkin_production
SENDGRID_API_KEY=your_sendgrid_api_key
RAILS_ENV=production
```

## Mobile Optimization

The application is optimized for mobile devices:

- Responsive design works on all screen sizes
- QR scanner works on mobile cameras
- Touch-friendly interface for door staff
- Offline-capable check-in (with proper PWA setup)

## Security Features

- CSRF protection on all forms
- Unique QR code tokens for each attendee
- Input validation and sanitization
- SQL injection prevention through Rails ORM

## Deployment

### Heroku Deployment

1. Create a new Heroku app:
   ```bash
   heroku create your-app-name
   ```

2. Add PostgreSQL addon:
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

3. Set environment variables:
   ```bash
   heroku config:set SENDGRID_API_KEY=your_key
   ```

4. Deploy:
   ```bash
   git push heroku main
   ```

5. Run migrations:
   ```bash
   heroku run rails db:migrate
   ```

## API Endpoints

The system includes RESTful API endpoints:

- `GET /api/v1/events/:id/stats` - Real-time event statistics
- `POST /scanner/:event_id/scan` - QR code scanning
- `POST /scanner/:event_id/manual` - Manual check-in

## Customization

### Branding

Update the following files to customize branding:
- `app/views/layouts/application.html.erb` - Main layout and styles
- `app/views/attendee_mailer/qr_code_email.html.erb` - Email template
- `app/controllers/application_controller.rb` - Default email sender

### Features

The modular design allows easy addition of:
- Custom attendee fields
- Badge printing integration
- Slack/Teams notifications
- Analytics and reporting
- Multiple event organizer accounts

## Testing

Run the test suite:
```bash
bundle exec rspec
```

## Support

For technical support or customization requests:
- Create issues in the project repository
- Contact Blackbird RSVP support

## License

This project is proprietary software developed for Blackbird RSVP.

---

Built with ❤️ by the Blackbird RSVP team