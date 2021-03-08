# ## Schema Information
#
# Table name: `donators`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`name`**        | `string`           |
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
#
class Donator < ApplicationRecord
  has_many :donations, inverse_of: :donator
  has_many :bundles, inverse_of: :donator
  has_many :bundle_definitions, through: :bundles
  has_many :keys, through: :bundles

  def assign_keys
    BundleDefinition.find_each do |bundle_definition|
      bundle = bundles.find_or_create_by!(bundle_definition: bundle_definition)
      BundleKeyAssignmentJob.perform_later(bundle.id)
    end
  end

  def total_donations
    donations.map(&:amount).reduce(Money.new(0), :+)
  end
end
