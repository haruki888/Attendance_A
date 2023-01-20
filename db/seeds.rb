# coding: utf-8
User.create!(name: "管理者",
            email: "sample@email.com",
            employee_number: "1",
            uid: "1",
            password: "password",
            password_confirmation: "password",
            admin: true)
            
User.create!(name: "上長A",
            email: "superior-a@email.com",
            employee_number: "2",
            uid: "2",
            password: "password",
            password_confirmation: "password",
            admin: false,
            superior: true)
            
User.create!(name: "上長B",
            email: "superior-b@email.com",
            employee_number: "3",
            uid: "3",
            password: "password",
            password_confirmation: "password",
            admin: false,
            superior: true)            
    
8.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               employee_number: n+4,
               uid: n+4,
               password: password,
               password_confirmation: password,
               admin: false,
               superior: false)
end




