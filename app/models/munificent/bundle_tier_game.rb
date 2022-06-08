module Munificent
  class BundleTierGame < ApplicationRecord
    belongs_to :bundle_tier
    belongs_to :game
  end
end
