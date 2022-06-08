Munificent::Factories.define :curated_streamer do
  sequence(:twitch_username) { |n| "streamer_#{n}" }
end
