class Event < ApplicationRecord
  include AASM

  ACTIVE_STATES = %w[accepted ignored tentative].freeze

  has_many :events_users, inverse_of: :event
  has_many :users, through: :events_users
  has_many :participants, -> { participant }, class_name: 'EventsUser', inverse_of: :event
  has_many :guests, -> { guest }, class_name: 'EventsUser', inverse_of: :event

  has_many :participants_users, through: :participants, source: :user
  has_many :guests_users, through: :guests, source: :user
  
  has_one :user_creator, -> { creator }, class_name: 'EventsUser', inverse_of: :event
  has_one :creator, through: :user_creator, source: :user

  validates :name, presence: true, length: { in: 1..30 }
  validates :description, length: { maximum: 500 }
  validates :location, length: { maximum: 100 }
  validates :date, :start_event, :end_event, presence: true
  validate :start_end_times

  scope :active_events, -> { joins(:events_users).where('events_users.state': ACTIVE_STATES).uniq }

  aasm column: 'state' do
    state :active, initial: true
    state :canceled

    event :cancel do
      transitions from: :active, to: :canceled
    end
  end

  private

  def start_end_times
    errors.add(:end_event, 'must be after start time') if end_event < start_event
  end
end
