
namespace :users do
  # Create or update a user from command line.
  # Usage:
  #   bin/rake users:add[email,password,name]
  # Example:
  #   bin/rake users:add[owner@example.com,Secret123!,Owner Name]
  # Behavior:
  # - Creates a new user when email does not exist.
  # - Updates name/password when email already exists.
  desc "Create or update a user: rake users:add[email,password,name]"
  task :add, [:email, :password, :name] => :environment do |_task, args|
    # Normalize input from positional task arguments.
    email = args[:email].to_s.strip
    password = args[:password].to_s
    name = args[:name].to_s.strip

    if email.empty? || password.empty? || name.empty?
      abort "Usage: rake users:add[email,password,name]"
    end

    user = User.find_or_initialize_by(email: email)
    user.name = name
    user.password = password
    user.password_confirmation = password
    user.save!

    # Keep output machine- and human-readable for quick scripting/debugging.
    puts "User ready: #{user.email} (id=#{user.id})"
  end
end
