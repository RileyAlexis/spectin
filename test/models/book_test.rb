# == Schema Information
#
# Table name: books
#
#  id                 :bigint           not null, primary key
#  authors            :string           default([]), not null, is an Array
#  cover_byte_size    :bigint
#  cover_content_type :string
#  cover_data         :binary
#  cover_filename     :string
#  description        :text
#  epub_byte_size     :bigint
#  epub_content_type  :string
#  epub_data          :binary
#  epub_filename      :string
#  identifier         :string
#  isbn               :string
#  language           :string
#  metadata           :jsonb            not null
#  published_at       :datetime
#  publisher          :string
#  source_format      :string           default("epub"), not null
#  spine_page_count   :integer
#  subtitle           :string
#  title              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :bigint           not null
#
# Indexes
#
#  index_books_on_authors                 (authors) USING gin
#  index_books_on_metadata                (metadata) USING gin
#  index_books_on_user_id                 (user_id)
#  index_books_on_user_id_and_identifier  (user_id,identifier)
#  index_books_on_user_id_and_title       (user_id,title)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class BookTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
