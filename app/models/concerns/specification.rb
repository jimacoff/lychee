module Specification
  extend ActiveSupport::Concern

  included do
    validates :specifications, specification: true
  end
end
