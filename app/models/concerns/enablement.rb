module Enablement
  extend ActiveSupport::Concern

  included do
    scope :enabled, -> { where(enabled: true) }
  end
end
