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
          :description,
          :publisher,
          :language,
          :isbn,
          :identifier,
          :source_format,
          :spine_page_count,
          :published_at,
          :description,
          :metadata,
          :cover_byte_size,
          :created_at,
          :updated_at
        ),
      T.untyped
    )
  end

  sig { void }
  def cover
    books_source = T.let(Book, T.untyped)
    controller = T.unsafe(self)
    book = books_source
      .select(:id, :updated_at, :cover_data, :cover_byte_size, :cover_content_type, :cover_filename)
      .find_by(id: controller.params[:id])

    if book.blank? || book.cover_data.blank?
      controller.head :not_found
      return
    end

    stale = controller.stale?(
      etag: [ book.id, book.updated_at&.to_i, book.cover_byte_size ],
      last_modified: book.updated_at,
      public: false
    )
    return unless stale

    controller.send_data(
      book.cover_data,
      type: book.cover_content_type.presence || "image/jpeg",
      disposition: "inline",
      filename: book.cover_filename.presence || "cover.jpg"
    )
  end
end
