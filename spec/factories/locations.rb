FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    precision { "specific" }
    archived { false }
  end
end
