# Main App Integration Guide

This guide shows how to integrate the check-in app with your existing Blackbird RSVP application using JWT authentication.

## 🚀 Getting Rails Running (First Time Setup)

### 1. Install Ruby Version Manager
```bash
# Install rbenv (recommended)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Add to shell profile
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# Install Ruby 3.1.0
rbenv install 3.1.0
rbenv global 3.1.0
```

### 2. Install Rails
```bash
gem install rails bundler
rails --version  # Should show Rails 7.x
```

### 3. Run the Check-in App
```bash
cd /Users/lauravaughn/Desktop/blackbird_checkin

# Install dependencies
bundle install

# Set up database
rails db:create
rails db:migrate

# Start server
rails server
```

Visit: **http://localhost:3000**

---

## 🔐 JWT Integration Setup

### Architecture Overview

```
Main App (app.blackbirdrsvp.com)
    ↓ Generates JWT token
    ↓ Redirects with token
Check-in App (checkin.blackbirdrsvp.com)
    ↓ Validates JWT
    ↓ Auto-login user
    ↓ Single sign-on experience
```

### 1. In Your Main App (Blackbird RSVP)

Add this service to generate JWT tokens:

```ruby
# app/services/jwt_service.rb
class JwtService
  JWT_SECRET = Rails.application.credentials.jwt_secret || ENV['JWT_SECRET']
  
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

Add controller action for redirecting to check-in app:

```ruby
# app/controllers/checkin_controller.rb
class CheckinController < ApplicationController
  def redirect_to_checkin
    token = JwtService.encode(current_user)
    checkin_url = "https://checkin.blackbirdrsvp.com?token=#{token}"
    redirect_to checkin_url
  end
end
```

Add route:
```ruby
# config/routes.rb
get '/checkin', to: 'checkin#redirect_to_checkin'
```

Add link in your main app:
```erb
<%= link_to "Event Check-in", checkin_path, class: "btn btn-primary" %>
```

### 2. Environment Variables

Both apps need the same JWT secret:

```bash
# .env (both apps)
JWT_SECRET=your-very-secure-secret-key-here
```

Generate a secure key:
```bash
rails secret  # Use this output as your JWT_SECRET
```

### 3. Domain Setup

For production, set up subdomains:

**DNS Records:**
- `app.blackbirdrsvp.com` → Your main app
- `checkin.blackbirdrsvp.com` → Check-in app

**Shared Cookies:** (Optional for enhanced UX)
```ruby
# config/application.rb (both apps)
config.session_store :cookie_store, 
  key: '_blackbird_session',
  domain: '.blackbirdrsvp.com'  # Dot prefix shares across subdomains
```

---

## 🎯 User Flow Example

1. **User logs into main app** at `app.blackbirdrsvp.com`
2. **Clicks "Event Check-in"** button
3. **Main app generates JWT** with user info
4. **Redirects** to `checkin.blackbirdrsvp.com?token=JWT_TOKEN`
5. **Check-in app validates JWT** and auto-logs user in
6. **User has seamless access** to event management
7. **Logout from either app** logs out of both

---

## 🧪 Testing the Integration

### Local Testing (Development)

1. **Start both apps:**
   ```bash
   # Terminal 1: Main app
   cd /path/to/main-app
   rails server -p 3000
   
   # Terminal 2: Check-in app  
   cd /Users/lauravaughn/Desktop/blackbird_checkin
   rails server -p 3001
   ```

2. **Test JWT generation:**
   ```ruby
   # In main app rails console
   user = User.first  # Or current user
   token = JwtService.encode(user)
   puts "http://localhost:3001?token=#{token}"
   ```

3. **Visit the URL** - should auto-login to check-in app

### Production Testing

1. **Deploy both apps** to your domains
2. **Set JWT_SECRET** environment variable (same on both)
3. **Test the flow** from main app → check-in app

---

## 🔧 Configuration Options

### Custom JWT Claims

Add more user data to JWT:

```ruby
# In main app
payload = {
  user_id: user.id,
  email: user.email,
  first_name: user.first_name,
  last_name: user.last_name,
  company: user.company,
  role: user.role,
  permissions: user.permissions,
  exp: 24.hours.from_now.to_i
}
```

### Logout Handling

```ruby
# In check-in app controller
def logout
  session.clear
  redirect_to "https://app.blackbirdrsvp.com/logout"
end
```

### Error Handling

```ruby
# In check-in app application_controller.rb
def main_app_login_url
  return_url = CGI.escape(request.original_url)
  "https://app.blackbirdrsvp.com/login?return_to=#{return_url}"
end
```

---

## 📋 Quick Checklist

- [ ] Install Ruby 3.1+ with rbenv
- [ ] Install Rails and bundle gems
- [ ] Get check-in app running locally
- [ ] Add JWT service to main app
- [ ] Set same JWT_SECRET in both apps
- [ ] Test token generation and validation
- [ ] Deploy to production subdomains
- [ ] Test complete user flow

## 🆘 Troubleshooting

**"JWT Decode Error"**
- Ensure same JWT_SECRET in both apps
- Check token isn't expired (24 hour limit)

**"Authentication Failed"** 
- Verify user object has required fields (email, first_name, last_name)
- Check JWT payload format

**"Can't access subdomain"**
- Verify DNS records point to correct servers
- Check SSL certificates for subdomains

Need help? The system is designed to be very forgiving and will redirect users back to the main app if anything goes wrong!