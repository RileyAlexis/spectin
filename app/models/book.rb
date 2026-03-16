class Book < ApplicationRecord
  belongs_to :user
  has_one :reading_progress, dependent: :destroy

  validates :title, presence: true
  validates :source_format, presence: true
  validates :epub_data, presence: true
end
