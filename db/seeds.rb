User.create!(name: "上長A",
            email: "sample-a@email.com",
            employee_number: 001,
            password: "password",
            password_confirmation: "password",
            superior: true)

User.create!(name: "上長B",
            email: "sample-b@email.com",
            employee_number: 002,
            password: "password",
            password_confirmation: "password",
            superior: true)

User.create!(name: "管理者",
            email: "sample@email.com",
            password: "password",
            password_confirmation: "password",
            admin: true)

            
60.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
              email: email,
              password: password,
              password_confirmation: password)
end
  