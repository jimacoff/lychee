module Markup
  extend ActiveSupport::Concern

  included do
    enum markup_format: [:html, :common_mark]
  end
end
