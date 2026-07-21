#### CREATE USERS
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
