# Helpers for building LibraryFile records with a controlled attachment size and blob
# timestamp, so size/date sorting can be asserted deterministically (the model derives
# both from the ActiveStorage blob rather than from its own columns).
module LibraryFileHelpers
  def create_library_file(user:, name:, bytes: 100, at: Time.current)
    file = build(:library_file, :without_attachment, user: user, name: name)
    file.attachment.attach(
      io: StringIO.new("x" * bytes), filename: name, content_type: "text/plain"
    )
    file.save!
    # Back-date the blob so "date" sorting has real spread; update_column skips callbacks.
    file.attachment.blob.update_column(:created_at, at)
    file
  end
end

RSpec.configure do |config|
  config.include LibraryFileHelpers
end
