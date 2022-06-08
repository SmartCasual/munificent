module Munificent
  class CharitySplit < ApplicationRecord
    belongs_to :donation, inverse_of: :charity_splits
    belongs_to :charity, inverse_of: :charity_splits

    monetize :amount
  end
end
