class EventsUser < ApplicationRecord
  include AASM

  belongs_to :event, inverse_of: :events_users
  belongs_to :user, inverse_of: :events_users

  enum user_role: [:creator, :participant, :guest]

  aasm column: 'state' do
    state :ignored, initial: true
    state :accepted, :tentative, :declined

    event :accept do
      transitions from: [:ignored, :tentative], to: :accepted
    end

    event :maybe do
      transitions from: :ignored, to: :tentative
    end

    event :decline do
      transitions from: [:ignored, :tentative, :accepted], to: :declined
    end
  end
end
