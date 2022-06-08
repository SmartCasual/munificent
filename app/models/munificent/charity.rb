module Munificent
  class Charity < ApplicationRecord
    validates :name, presence: true

    has_many :charity_fundraisers, inverse_of: :charity, dependent: :destroy
    has_many :fundraisers, through: :charity_fundraisers
    has_many :charity_splits, inverse_of: :charity, dependent: :destroy
  end
end
