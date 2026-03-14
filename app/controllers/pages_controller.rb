# typed: false

require "fileutils"
require "securerandom"
require "open3"

class PagesController < ApplicationController
  # extend T::Sig

  # sig { void }
  def home
  end

  def epub_preview
    @max_pages = 25
    @pages = []
  end

  def epub_preview_upload
    @max_pages = 25
    @pages = []
    @save_to_library = params[:save_to_library] == "1"
    @library_user_id = params[:library_user_id].to_s

    uploaded_file = params[:epub_file]
    if uploaded_file.blank?
      flash.now[:alert] = "Select an EPUB file to preview."
      render :epub_preview, status: :unprocessable_entity
      return
    end

    unless uploaded_file.respond_to?(:path)
      flash.now[:alert] = "Upload failed. Try selecting the file again."
      render :epub_preview, status: :unprocessable_entity
      return
    end

    begin
      require "epub/parser"

      epub_path = normalize_uploaded_path(uploaded_file.path)
      unless File.file?(epub_path)
        flash.now[:alert] = "Uploaded EPUB file is not readable from disk."
        render :epub_preview, status: :unprocessable_entity
        return
      end

      preview_id = SecureRandom.hex(10)
      parser_class = Object.const_get("EPUB").const_get("Parser")
      book = begin
        parser_class.parse(epub_path)
      rescue StandardError => e
        raise StandardError, "parse stage failed: #{e.class} - #{e.message}"
      end

      begin
        extract_epub(epub_path, preview_id)
      rescue StandardError => e
        raise StandardError, "extract stage failed: #{e.class} - #{e.message}"
      end

      @book_title = book.metadata.title.to_s.presence || uploaded_file.original_filename
      @book_creators = Array(book.metadata.creators).map(&:to_s).reject(&:blank?)

      if @save_to_library
        @saved_book = save_uploaded_book(uploaded_file, book)
      end

      index = 0
      book.each_page_on_spine do |page|
        break if index >= @max_pages

        media_type = page.media_type.to_s
        next unless media_type.include?("xhtml") || media_type.include?("html")

        asset_rel_path = page.entry_name.to_s
        asset_full_path = safe_asset_path(preview_id, asset_rel_path)
        raw_content = asset_full_path && File.file?(asset_full_path) ? File.read(asset_full_path) : ""
        text_only = helpers.strip_tags(raw_content).squish

        index += 1
        @pages << {
          index: index,
          entry_name: asset_rel_path,
          media_type: media_type,
          snippet: text_only.first(180),
          preview_url: epub_preview_asset_path(preview_id: preview_id, asset_path: asset_rel_path)
        }
      end

      if @pages.empty?
        flash.now[:alert] = "No HTML/XHTML spine pages found in this EPUB."
      end
    rescue StandardError => e
      Rails.logger.error("EPUB preview failed: #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace.first(8).join("\n")) if e.backtrace
      flash.now[:alert] = "EPUB preview failed: #{e.class} - #{e.message}"
    end

    render :epub_preview
  end

  def epub_preview_asset
    asset_path = params[:asset_path].to_s
    if params[:format].present?
      asset_path = "#{asset_path}.#{params[:format]}"
    end

    full_path = safe_asset_path(params[:preview_id], asset_path)
    if full_path.blank? || !File.file?(full_path)
      head :not_found
      return
    end

    send_file full_path, type: mime_type_for(full_path), disposition: "inline"
  end

  # sig { returns(String) }
  def greeting
    "Hello from PagesController"
  end

  private

  def extract_epub(epub_path, preview_id)
    extraction_dir = File.expand_path(File.join(preview_root_dir, preview_id.to_s))
    FileUtils.rm_rf(extraction_dir)
    FileUtils.mkdir_p(extraction_dir)
    extraction_dir = File.realpath(extraction_dir)

    stdout, stderr, status = Open3.capture3("unzip", "-qq", "-o", epub_path.to_s, "-d", extraction_dir)
    return extraction_dir if status.success?

    message = stderr.to_s.strip
    message = stdout.to_s.strip if message.empty?
    message = "unknown unzip failure" if message.empty?
    raise "unzip failed: #{message}"

    extraction_dir
  end

  def safe_asset_path(preview_id, asset_path)
    return nil if preview_id.blank? || asset_path.blank?

    base_dir = File.expand_path(File.join(preview_root_dir, preview_id.to_s))
    requested_path = File.expand_path(asset_path.to_s, base_dir)
    return nil unless requested_path.start_with?("#{base_dir}/")

    requested_path
  end

  def preview_root_dir
    Rails.root.join("tmp", "epub_preview_assets").to_s
  end

  def normalize_uploaded_path(path)
    candidate = path.to_s.strip
    candidate = "/#{candidate}" unless candidate.start_with?("/")
    File.realpath(candidate)
  rescue StandardError
    File.expand_path(candidate, Rails.root.to_s)
  end

  def mime_type_for(path)
    rack_mime = Object.const_get("Rack").const_get("Mime")
    mime = rack_mime.mime_type(File.extname(path), "application/octet-stream")
    text_like = mime.start_with?("text/") || mime == "application/xhtml+xml" || mime.end_with?("+xml") || mime == "application/xml"
    text_like ? "#{mime}; charset=utf-8" : mime
  end

  def save_uploaded_book(uploaded_file, parsed_book)
    user = User.find_by(id: @library_user_id)
    unless user
      flash.now[:alert] = "Could not save book: user not found (User ID #{@library_user_id})."
      return nil
    end

    book_record = user.books.build(
      title: parsed_book.metadata.title.to_s.presence || uploaded_file.original_filename,
      authors: Array(parsed_book.metadata.creators).map(&:to_s).reject(&:blank?),
      language: Array(parsed_book.metadata.languages).map(&:to_s).first,
      publisher: Array(parsed_book.metadata.publishers).map(&:to_s).first,
      identifier: Array(parsed_book.metadata.identifiers).map(&:to_s).first,
      description: Array(parsed_book.metadata.descriptions).map(&:to_s).first,
      epub_data: File.binread(uploaded_file.path),
      epub_filename: uploaded_file.original_filename,
      epub_content_type: uploaded_file.content_type.presence || "application/epub+zip",
      epub_byte_size: uploaded_file.size,
      metadata: {
        titles: Array(parsed_book.metadata.titles).map(&:to_s),
        creators: Array(parsed_book.metadata.creators).map(&:to_s),
        subjects: Array(parsed_book.metadata.subjects).map(&:to_s)
      }
    )

    if book_record.save
      flash.now[:notice] = "Saved to library as Book ##{book_record.id}."
      book_record
    else
      flash.now[:alert] = "Could not save book: #{book_record.errors.full_messages.join(', ')}"
      nil
    end
  rescue StandardError => e
    flash.now[:alert] = "Could not save book: #{e.class} - #{e.message}"
    nil
  end

  # sig { returns(ActionController::Parameters) }
  def page_params
    params.require(:page).permit(:title, :body)
  end
end
