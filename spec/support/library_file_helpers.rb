# Helpers for building LibraryFile records with a controlled attachment size and
# record timestamp, so size/date sorting can be asserted deterministically.
module LibraryFileHelpers
  def create_library_file(user:, name:, bytes: 100, at: Time.current)
    file = build(:library_file, :without_attachment, user: user, name: name)
    file.attachment.attach(
      io: StringIO.new("x" * bytes), filename: name, content_type: "text/plain"
    )
    file.save!
    # Back-date the record so "date" sorting has real spread; update_column skips callbacks.
    file.update_column(:created_at, at)
    file
  end
end

RSpec.configure do |config|
  config.include LibraryFileHelpers
end
