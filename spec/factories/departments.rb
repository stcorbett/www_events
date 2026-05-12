FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Department #{n}" }
    archived { false }
  end
end
