module Munificent
  class CharityFundraiser < ApplicationRecord
    belongs_to :fundraiser, inverse_of: :charity_fundraisers
    belongs_to :charity, inverse_of: :charity_fundraisers
  end
end
