namespace :users do
  desc "Create or update a user: rake users:add[email,password,name]"
  task :add, [:email, :password, :name] => :environment do |_task, args|
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

    puts "User ready: #{user.email} (id=#{user.id})"
  end
end
