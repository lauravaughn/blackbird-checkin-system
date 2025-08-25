class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  # For JWT integration with main app
  def self.from_jwt_payload(payload)
    user = find_or_initialize_by(email: payload['email'])
    
    # Update user info from main app
    user.assign_attributes(
      first_name: payload['first_name'],
      last_name: payload['last_name'],
      main_app_user_id: payload['user_id'],
      role: payload['role'] || 'organizer'
    )
    
    user.save!
    user
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def organizer?
    role == 'organizer' || role == 'admin'
  end
  
  def admin?
    role == 'admin'
  end
end