require 'rqrcode'
require 'rqrcode_png'

class Attendee < ApplicationRecord
  belongs_to :event
  has_one :check_in, dependent: :destroy
  
  validates :email, presence: true, uniqueness: { scope: :event_id }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :qr_code_token, presence: true, uniqueness: true
  
  before_validation :generate_qr_code_token, on: :create
  after_create :send_qr_code_email
  
  scope :checked_in, -> { joins(:check_in).where(check_ins: { checked_in: true }) }
  scope :not_checked_in, -> { left_joins(:check_in).where(check_ins: { id: nil }).or(left_joins(:check_in).where(check_ins: { checked_in: false })) }
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def checked_in?
    check_in&.checked_in? || false
  end
  
  def check_in_time
    check_in&.checked_in_at
  end
  
  def generate_qr_code
    qr = RQRCode::QRCode.new(qr_code_url)
    qr.as_png(size: 300)
  end
  
  def qr_code_url
    # This would be your app's domain + check-in path
    "https://your-app.com/check_in/#{qr_code_token}"
  end
  
  private
  
  def generate_qr_code_token
    self.qr_code_token ||= SecureRandom.urlsafe_base64(32)
  end
  
  def send_qr_code_email
    AttendeeMailer.qr_code_email(self).deliver_later
  end
end