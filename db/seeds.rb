# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# password : test12345

User.destroy_all

User.create!([{
  name: "Donald",
  email: "donald@gmail.com",
  #password_digest: "$2a$12$DEIqmZIHNyIPA8N2he2e1Oj6veYzF3oG9n59I/K7.lEwRecjsoYS."
  password: "test12345",
  password_confirmation: "test12345"
},
{
  name: "Mickey",
  email: "mickey@gmail.com",
  password: "test12345",
  password_confirmation: "test12345"
},
{
  name: "Popeye",
  email: "popeye@gmail.com",
  password: "test12345",
  password_confirmation: "test12345"
},
{
  name: "Olive",
  email: "olive@gmail.com",
  password: "test12345",
  password_confirmation: "test12345"
},
{
  name: "Pluto",
  email: "pluto@gmail.com",
  password: "test12345",
  password_confirmation: "test12345"
},
{
  name: "Daisy",
  email: "daisy@gmail.com",
  password: "test12345",
  password_confirmation: "test12345"
},
{
  name: "Scrooge",
  email: "scrooge@gmail.com",
  password: "test12345",
  password_confirmation: "test12345"
},
{
  name: "Glomgold",
  email: "glomgold@gmail.com",
  password: "test12345",
  password_confirmation: "test12345"
},
{
  name: "Goofy",
  email: "goofy@gmail.com",
  password: "test12345",
  password_confirmation: "test12345"

}])

p "Created #{User.count} users"
