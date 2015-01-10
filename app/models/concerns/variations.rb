module Variations
  extend ActiveSupport::Concern

  included do
    validates :variations, variations: true

    validates :variations, presence: true, if: :variants?
    validates :variants, length: { minimum: 1 }, if: :variations?
  end

  def variations?
    variations && variations.present?
  end

  def variants?
    variants && variants.any?
  end
end
