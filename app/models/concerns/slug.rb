module Slug
  extend ActiveSupport::Concern

  included do
    validates :name, :generated_slug, presence: true
    acts_as_url :name, url_attribute: :generated_slug, sync_url: true
  end

  def slug
    specified_slug || generated_slug
  end

  def slug=(specified_slug)
    self.specified_slug = specified_slug
  end
end
