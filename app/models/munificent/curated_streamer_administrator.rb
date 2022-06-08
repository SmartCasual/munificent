module Munificent
  class CuratedStreamerAdministrator < ApplicationRecord
    belongs_to :curated_streamer, inverse_of: :curated_streamer_administrators
    belongs_to :donator, inverse_of: :curated_streamer_administrators
  end
end
