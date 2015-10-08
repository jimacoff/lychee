module Routable
  extend ActiveSupport::Concern

  include Enablement

  included do
    has_one :path, as: :routable
  end

  def uri_path
    return nil unless path.present?

    "/#{path.self_and_ancestors.reverse.map(&:segment).join('/')}"
  end

  def routable?
    enabled? && path.present?
  end
end
