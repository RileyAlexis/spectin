class Book < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :source_format, presence: true
  validates :epub_data, presence: true
end
