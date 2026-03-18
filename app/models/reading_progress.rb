# == Schema Information
#
# Table name: reading_progresses
#
#  id         :bigint           not null, primary key
#  bookmarks  :jsonb            not null
#  last_cfi   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_reading_progresses_on_book_id              (book_id)
#  index_reading_progresses_on_user_id              (user_id)
#  index_reading_progresses_on_user_id_and_book_id  (user_id,book_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#  fk_rails_...  (user_id => users.id)
#
class ReadingProgress < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :book_id, uniqueness: { scope: :user_id }
end
