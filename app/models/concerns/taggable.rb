module Taggable
  extend ActiveSupport::Concern

  included do
    scope :all_tags, -> (tags) { where('tags @> ARRAY[?]', tags) }
    scope :any_tag, -> (tags) { where('tags && ARRAY[?]', tags) }
  end

  def add_tag(value)
    tags_will_change!
    tags.push value
  end

  def delete_tag(value)
    tags_will_change!
    tags.delete value
  end
end
