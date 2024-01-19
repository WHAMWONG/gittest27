class Todo < ApplicationRecord
  has_many :todo_categories, dependent: :destroy
  has_many :attachments, dependent: :destroy

  belongs_to :user

  enum priority: %w[low medium high], _suffix: true
  enum recurrence: %w[daily weekly monthly], _suffix: true

  validates :title, uniqueness: { scope: :user_id }

  # validations

  # end for validations

  class << self
  end
end
