# Quick Start Guide

Get your Blackbird RSVP check-in system running in minutes!

## Prerequisites

Make sure you have these installed:
- Ruby 2.7+ (check with `ruby --version`)
- PostgreSQL (check with `psql --version`)
- Node.js (check with `node --version`)

## Setup Steps

1. **Install Rails** (if not already installed):
   ```bash
   gem install rails
   ```

2. **Navigate to project directory**:
   ```bash
   cd blackbird_checkin
   ```

3. **Run the setup script**:
   ```bash
   ./bin/setup
   ```

4. **Create and migrate database**:
   ```bash
   rails db:create
   rails db:migrate
   ```

5. **Start the server**:
   ```bash
   rails server
   ```

6. **Open in browser**: http://localhost:3000

## Test the System

1. **Create your first event**:
   - Click "New Event"
   - Fill in event details
   - Save

2. **Import test attendees**:
   - Download the CSV template
   - Add a few test entries with real email addresses
   - Import the CSV file

3. **Test QR scanning**:
   - Go to Scanner interface
   - Allow camera permissions
   - Test with the generated QR codes

## Common Issues

### Database Connection Error
```bash
# Make sure PostgreSQL is running
brew services start postgresql  # macOS with Homebrew
sudo service postgresql start   # Linux
```

### Gem Installation Issues
```bash
# If bundler fails, try:
gem install bundler
bundle install
```

### Permission Errors
```bash
# If you get permission errors:
sudo gem install rails
# Or use rbenv/rvm for Ruby version management
```

## Next Steps

- Configure email settings for production
- Customize branding and styling
- Set up SSL certificate for HTTPS
- Deploy to Heroku or your preferred platform

## Need Help?

- Check README.md for detailed documentation
- Review error logs: `tail -f log/development.log`
- Ensure all prerequisites are met

Happy event managing! 🎉