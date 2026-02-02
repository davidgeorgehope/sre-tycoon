class Score < ApplicationRecord
  validates :company_name, presence: true

  scope :winners, -> { where(won: true).order(final_score: :desc) }
  scope :hall_of_shame, -> { where(won: false).order(final_score: :desc) }
  scope :recent, -> { order(completed_at: :desc).limit(20) }
end
