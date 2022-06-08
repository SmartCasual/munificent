module Munificent
  class Game < ApplicationRecord
    has_many :bundle_tier_games, inverse_of: :game, dependent: :destroy
    has_many :keys, inverse_of: :game, dependent: :destroy

    validates :name, presence: true

    accepts_nested_attributes_for :keys, allow_destroy: true

    def bulk_key_entry; end

    def bulk_key_entry=(codes)
      requested_codes = codes.split("\n")
      existing_codes = keys.map(&:code)
      new_codes = (requested_codes - existing_codes).map { |code| Key.new(code:) }

      self.keys += new_codes
    end
  end
end
