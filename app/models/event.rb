class Event < ApplicationRecord
  has_many :attendees, dependent: :destroy
  has_many :check_ins, through: :attendees
  
  validates :name, presence: true
  validates :date, presence: true
  validates :venue, presence: true
  
  scope :upcoming, -> { where('date >= ?', Date.current) }
  scope :past, -> { where('date < ?', Date.current) }
  
  def total_attendees
    attendees.count
  end
  
  def checked_in_count
    check_ins.where(checked_in: true).count
  end
  
  def check_in_percentage
    return 0 if total_attendees.zero?
    (checked_in_count.to_f / total_attendees * 100).round(1)
  end
  
  def pending_check_ins
    total_attendees - checked_in_count
  end
end