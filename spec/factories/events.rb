FactoryBot.define do
  factory :event do
    title { Faker::Educator.course_name }
    event_description { Faker::Lorem.paragraph }
    start_date { 1.day.from_now }
    end_date { 2.days.from_now }
    location { Faker::Address.full_address }
    capacity { rand(10..100) }
    association :user
  end
end 
