FactoryBot.define do
  factory :blog_post do
    title { "MyString" }
    content { "MyText" }
    slug { "MyString" }
    published { false }
    published_at { "2025-01-14 14:31:20" }
    user { nil }
  end
end
