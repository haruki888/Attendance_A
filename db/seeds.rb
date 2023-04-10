# coding: utf-8
User.create!(name: "管理者",
            email: "sample@email.com",
            affiliation: "管理部",
            employee_number: "1",
            uid: "1",
            password: "password",
            password_confirmation: "password",
            admin: true)
            
User.create!(name: "上長A",
            email: "sample-a@email.com",
            affiliation: "人事部",
            employee_number: "2",
            uid: "2",
            password: "password",
            password_confirmation: "password",
            admin: false,
            superior: true)
            
User.create!(name: "上長B",
            email: "sample-b@email.com",
            affiliation: "店舗部",
            employee_number: "3",
            uid: "3",
            password: "password",
            password_confirmation: "password",
            admin: false,
            superior: true)            
    
5.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               affiliation: "販売部",
               employee_number: n+4,
               uid: n+4,
               password: password,
               password_confirmation: password,
               admin: false,
               superior: false)
end




