# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

puts "Creating roles..."
YAML.load(ENV['ROLES']).each do |role|
  Role.find_or_create_by_name({ :name => role }, :without_protection => true)
  puts "\tCreated role: " << role
end

puts "Creating default admin account..."
user = User.find_or_create_by_handle(:handle => ENV['ADMIN_HANDLE'].dup,
                                     :email => ENV['ADMIN_EMAIL'].dup,
                                     :password => ENV['ADMIN_PASSWORD'].dup,
                                     :password_confirmation => ENV['ADMIN_PASSWORD'].dup)
puts "Created admin: " << user.handle
user.add_role :admin
