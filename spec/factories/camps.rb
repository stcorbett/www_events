FactoryBot.define do
  factory :camp do
    sequence(:name) { |n| "Camp #{n}" }
    year { LakesOfFireConfig.year }
    archived { false }
  end
end
