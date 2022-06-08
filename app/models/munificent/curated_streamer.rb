module Munificent
  class CuratedStreamer < ApplicationRecord
    has_many :curated_streamer_administrators, dependent: :destroy, inverse_of: :curated_streamer
    has_many :admins, through: :curated_streamer_administrators, source: :donator
    has_many :donations, inverse_of: :curated_streamer, dependent: :nullify

    def to_param
      twitch_username
    end
  end
end
