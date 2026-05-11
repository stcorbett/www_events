FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    sequence(:uid) { |n| "google-user-#{n}" }
    sequence(:email) { |n| "user-#{n}@example.test" }
    name { "Spec User" }
    image { "https://example.test/avatar.png" }
    token { "oauth-token" }
    expires_at { 1.hour.from_now }
    hearts { {} }
  end
end
