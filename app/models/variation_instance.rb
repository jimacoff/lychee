class VariationInstance < ActiveRecord::Base
  include Metadata

  belongs_to :variation
  belongs_to :variant

  validates :variation, :variant, :value, presence: true
end
