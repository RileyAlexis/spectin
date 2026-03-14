class AddCoverColumnsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :cover_data, :binary
    add_column :books, :cover_filename, :string
    add_column :books, :cover_content_type, :string
    add_column :books, :cover_byte_size, :bigint
  end
end
