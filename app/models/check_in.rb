class CheckIn < ApplicationRecord
  belongs_to :attendee
  has_one :event, through: :attendee
  
  validates :attendee_id, uniqueness: true
  validates :check_in_method, inclusion: { in: %w[qr_code manual] }
  
  scope :checked_in, -> { where(checked_in: true) }
  scope :today, -> { where(checked_in_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :by_method, ->(method) { where(check_in_method: method) }
  
  def self.check_in_attendee(attendee, method: 'qr_code', checked_by: nil)
    check_in = find_or_initialize_by(attendee: attendee)
    check_in.assign_attributes(
      checked_in: true,
      checked_in_at: Time.current,
      check_in_method: method,
      checked_by: checked_by
    )
    check_in.save!
    check_in
  end
  
  def self.manual_check_in(attendee, user)
    check_in_attendee(attendee, method: 'manual', checked_by: user&.email || 'Staff')
  end
  
  def duration_since_check_in
    return nil unless checked_in_at
    Time.current - checked_in_at
  end
end