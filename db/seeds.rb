require "securerandom"

[
  { email: "demo@library.local",  name: "Demo User",  password: "Password123!" },
  { email: "owner@library.local", name: "Owner User", password: "Password123!" }
].each do |attrs|
  User.find_or_initialize_by(email: attrs[:email]).tap do |user|
    user.name = attrs[:name]
    if user.new_record?
      user.password = attrs[:password]
      user.password_confirmation = attrs[:password]
    end
    user.save!
  end
end

sample_names = %w[
  Q3-Roadmap.pdf Design-Tokens.sketch Team-Photo.jpg Meeting-Notes.txt Budget.xlsx
  Contract-Draft.docx Logo-Assets.zip Onboarding.md Invoice-2026-07.pdf Retro-Notes.md
  Architecture.png Release-Plan.xlsx Keynote.key Screenshot.png Backup.tar
  Palette.svg Roadmap-Q4.pdf Handbook.txt Demo-Script.md Analytics.csv
]

seed_files = lambda do |user, count|
  existing = user.library_files.count
  next if existing >= count

  (existing...count).each do |i|
    base = sample_names[i % sample_names.size]
    name = i < sample_names.size ? base : "#{File.basename(base, '.*')}-#{i + 1}#{File.extname(base)}"
    bytes = 1024 * (2 + (i * 53) % 250)
    created = Time.current - ((i * 53) % 120).days - ((i * 17) % 24).hours

    file = user.library_files.new(name: name, visibility: (i % 5).zero? ? :private : :public)
    file.attachment.attach(
      io: StringIO.new(SecureRandom.alphanumeric(bytes)),
      filename: name,
      content_type: "application/octet-stream"
    )
    file.save!
    # Blob drives the "Modified" column and date sort; keep the record in step for realism.
    file.attachment.blob.update_column(:created_at, created)
    file.update_column(:created_at, created)
  end
end

demo  = User.find_by!(email: "demo@library.local")
owner = User.find_by!(email: "owner@library.local")

seed_files.call(demo, 40)
seed_files.call(owner, 6)

puts "Seeded #{User.count} users, #{LibraryFile.count} library files " \
     "(demo=#{demo.library_files.count}, owner=#{owner.library_files.count})."
