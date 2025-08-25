# Deploy to Heroku - Complete Guide

Your check-in app is ready to deploy! This creates a completely separate application that won't affect your main Blackbird RSVP app.

## 🚀 Quick Deployment (5 minutes)

### Step 1: Install Heroku CLI (One-time setup)
```bash
# On macOS with Homebrew
brew tap heroku/brew && brew install heroku

# Or download installer from: https://devcenter.heroku.com/articles/heroku-cli
```

### Step 2: Login to Heroku
```bash
heroku login
# This opens a browser window to authenticate
```

### Step 3: Create Your Check-in App (Separate from main app)
```bash
cd /Users/lauravaughn/Desktop/blackbird_checkin

# Create a new Heroku app (choose a unique name)
heroku create blackbird-checkin-demo
# Or: heroku create your-custom-name-here

# Add PostgreSQL database
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set RAILS_ENV=production
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set RAILS_LOG_TO_STDOUT=true

# Optional: Set JWT secret for main app integration
heroku config:set JWT_SECRET=$(openssl rand -hex 64)

# Optional: Add SendGrid for emails (free tier)
heroku addons:create sendgrid:starter
```

### Step 4: Deploy
```bash
# Push to Heroku (this triggers deployment)
git push heroku main

# Open your new app
heroku open
```

**That's it! Your check-in app is live!** 🎉

---

## 🔧 Configuration Options

### Custom Domain (Optional)
```bash
# Add custom domain (if you have one)
heroku domains:add checkin.blackbirdrsvp.com

# Then update your DNS:
# CNAME: checkin.blackbirdrsvp.com → your-app-name.herokuapp.com
```

### Environment Variables
```bash
# View current config
heroku config

# Add email settings (if using custom SMTP)
heroku config:set SENDGRID_API_KEY=your-api-key-here
heroku config:set APP_HOST=your-app-name.herokuapp.com

# Add JWT secret (for main app integration)
heroku config:set JWT_SECRET=your-secure-secret-key
```

### Database Management
```bash
# View database info
heroku pg:info

# Run database migrations (if needed)
heroku run rails db:migrate

# Open database console
heroku pg:psql

# Reset database (DANGER: deletes all data)
heroku pg:reset DATABASE_URL --confirm your-app-name
heroku run rails db:migrate
```

---

## 🧪 Testing Your Deployed App

Once deployed, test the complete flow:

1. **Visit your app URL** (heroku open shows it)
2. **Create a test event**
3. **Upload the sample CSV file** (sample_attendees.csv)
4. **Try the QR scanner** on mobile
5. **Check the dashboard** for live stats

---

## 🔗 Integration with Main Blackbird App

### In Your Main App
Add this service to generate JWT tokens:

```ruby
# app/services/jwt_service.rb
class JwtService
  JWT_SECRET = ENV['JWT_SECRET'] # Same as check-in app
  
  def self.encode(user)
    payload = {
      user_id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role || 'organizer',
      exp: 24.hours.from_now.to_i
    }
    
    JWT.encode(payload, JWT_SECRET, 'HS256')
  end
end
```

Add controller and route:
```ruby
# app/controllers/checkin_controller.rb
class CheckinController < ApplicationController
  def redirect_to_checkin
    token = JwtService.encode(current_user)
    checkin_url = "https://your-heroku-app.herokuapp.com?token=#{token}"
    redirect_to checkin_url
  end
end

# config/routes.rb
get '/checkin', to: 'checkin#redirect_to_checkin'
```

Add button in your main app:
```erb
<%= link_to "Event Check-in", checkin_path, 
           class: "btn btn-primary", 
           target: "_blank" %>
```

---

## 🛡️ Security Checklist

- [ ] Set strong JWT_SECRET (64+ random characters)
- [ ] Use HTTPS (force_ssl is enabled in production)
- [ ] Don't commit sensitive data to git
- [ ] Set up proper SendGrid API key
- [ ] Configure correct APP_HOST environment variable

---

## 📊 Monitoring & Logs

```bash
# View real-time logs
heroku logs --tail

# View app metrics
heroku ps
heroku pg:info

# Scale if needed (costs money)
heroku ps:scale web=2
```

---

## 💰 Cost Estimate

**Free tier includes:**
- App hosting (550 dyno hours/month)
- PostgreSQL database (10,000 rows)
- SendGrid emails (100/day)

**Estimated monthly cost: $0** for light usage

**Upgrade when needed:**
- Hobby dyno: $7/month (always on)
- Standard PostgreSQL: $9/month (10M rows)
- More SendGrid emails: $15/month (40,000 emails)

---

## 🆘 Troubleshooting

**App won't start:**
```bash
heroku logs --tail
# Look for error messages

# Common fixes:
heroku run rails db:migrate
heroku restart
```

**Database issues:**
```bash
heroku pg:reset DATABASE_URL --confirm your-app-name
heroku run rails db:migrate
```

**Email not working:**
- Check SendGrid addon is installed
- Verify SENDGRID_API_KEY is set
- Check spam folder

## ✅ Success Checklist

After deployment:

- [ ] App loads without errors
- [ ] Can create events
- [ ] CSV import works
- [ ] QR codes generate properly
- [ ] Scanner interface works on mobile
- [ ] Dashboard shows real-time stats
- [ ] Manual check-in functions
- [ ] JWT integration tested (if connected to main app)

Your check-in system is now live and completely separate from your main Blackbird RSVP application! 🎉