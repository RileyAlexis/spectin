class AddEpubBinaryColumnsToBooks < ActiveRecord::Migration[8.0]
  def change
    change_table :books, bulk: true do |t|
      t.binary :epub_data
      t.string :epub_filename
      t.string :epub_content_type
      t.bigint :epub_byte_size
    end
  end
end
