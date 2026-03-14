# typed: strict

class LibraryController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    books_source = T.let(Book, T.untyped)

    @books = T.let(
      books_source
        .includes(:user)
        .order(created_at: :desc)
        .select(
          :id,
          :user_id,
          :title,
          :subtitle,
          :authors,
          :publisher,
          :language,
          :isbn,
          :identifier,
          :source_format,
          :spine_page_count,
          :published_at,
          :description,
          :metadata,
          :created_at,
          :updated_at
        ),
      T.untyped
    )
  end
end
