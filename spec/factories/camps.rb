FactoryBot.define do
  factory :camp do
    sequence(:name) { |n| "Camp #{n}" }
    archived { false }
  end
end
