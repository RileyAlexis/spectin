class User < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :reading_progresses, dependent: :destroy

  validates :email, presence: true, uniqueness: true
end
