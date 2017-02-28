# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name: "Example User",
             email: "example@user.com",
             password: "foobar",
             password_confirmation: "foobar")

User.create!(name: "Finding Forrester",
             email: "forrester@me.com",
             password: "f",
             password_confirmation: "f")

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@user.com"
  password = "p"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end

