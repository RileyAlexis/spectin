#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "cgi"
require "epub/parser"

if ARGV.empty?
  warn "Usage: bundle exec ruby script/epub_preview.rb path/to/book.epub [max_pages]"
  exit 1
end

epub_path = File.expand_path(ARGV[0])
max_pages = ARGV[1]&.to_i

unless File.exist?(epub_path)
  warn "EPUB file not found: #{epub_path}"
  exit 1
end

book = EPUB::Parser.parse(epub_path)

timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
book_slug = File.basename(epub_path, ".epub").downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-$|/, "")
run_dir = File.join("tmp", "epub_preview", "#{book_slug}-#{timestamp}")
pages_dir = File.join(run_dir, "pages")

FileUtils.mkdir_p(pages_dir)

page_rows = []
index = 0

book.each_page_on_spine do |page|
  break if max_pages && index >= max_pages

  media_type = page.media_type.to_s
  next unless media_type.include?("xhtml") || media_type.include?("html")

  index += 1

  source_name = File.basename(page.entry_name.to_s)
  safe_name = source_name.empty? ? "page-#{index}.xhtml" : source_name
  filename = format("%03d-%s", index, safe_name.gsub(/[^a-zA-Z0-9._-]/, "_"))
  output_path = File.join(pages_dir, filename)

  content = page.read.to_s
  File.write(output_path, content)

  snippet = content.gsub(/<[^>]*>/, " ").gsub(/\s+/, " ").strip
  snippet = snippet[0, 180]

  page_rows << {
    index: index,
    entry_name: page.entry_name.to_s,
    media_type: media_type,
    filename: filename,
    snippet: snippet
  }
end

if page_rows.empty?
  warn "No spine pages with HTML/XHTML content were found in: #{epub_path}"
  exit 1
end

title = book.metadata.title.to_s
creators = Array(book.metadata.creators).map(&:to_s).reject(&:empty?)

list_items = page_rows.map do |row|
  "<li><a href=\"pages/#{CGI.escapeHTML(row[:filename])}\">Page #{row[:index]}: #{CGI.escapeHTML(row[:entry_name])}</a><br><small>#{CGI.escapeHTML(row[:snippet])}</small></li>"
end.join("\n")

index_html = <<~HTML
  <!doctype html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>EPUB Preview - #{CGI.escapeHTML(title.empty? ? File.basename(epub_path) : title)}</title>
      <style>
        body {
          font-family: Georgia, "Times New Roman", serif;
          margin: 2rem;
          line-height: 1.4;
          max-width: 980px;
        }
        h1 { margin-bottom: 0.2rem; }
        .meta { color: #555; margin-bottom: 1.2rem; }
        ul { padding-left: 1.2rem; }
        li { margin-bottom: 0.85rem; }
        small { color: #666; }
        code { background: #f4f4f4; padding: 0.1rem 0.3rem; border-radius: 4px; }
      </style>
    </head>
    <body>
      <h1>#{CGI.escapeHTML(title.empty? ? File.basename(epub_path) : title)}</h1>
      <div class="meta">
        <div><strong>Source:</strong> <code>#{CGI.escapeHTML(epub_path)}</code></div>
        <div><strong>Creators:</strong> #{CGI.escapeHTML(creators.empty? ? "(none)" : creators.join(", "))}</div>
        <div><strong>Pages exported:</strong> #{page_rows.length}</div>
      </div>
      <h2>Spine Pages</h2>
      <ul>
        #{list_items}
      </ul>
    </body>
  </html>
HTML

index_path = File.join(run_dir, "index.html")
File.write(index_path, index_html)

puts "Preview generated: #{File.expand_path(run_dir)}"
puts "Open this file in your browser: #{File.expand_path(index_path)}"
