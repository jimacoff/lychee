class VariationInstance < ActiveRecord::Base
  has_paper_trail

  include Metadata

  belongs_to :variation
  belongs_to :variant

  validates :variation, :variant, :value, presence: true
end
