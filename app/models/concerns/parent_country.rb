module ParentCountry
  extend ActiveSupport::Concern

  included do
    belongs_to :country
  end
end
