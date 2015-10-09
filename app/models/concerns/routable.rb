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

  def create_default_path
    fail 'not implemented'
  end

  def default_parent_path
    fail 'not implemented'
  end
end
