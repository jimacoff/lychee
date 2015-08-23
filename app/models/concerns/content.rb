module Content
  extend ActiveSupport::Concern

  include Metadata
  include Slug
  include Taggable

  # has_many :image_instances
  # has_many :images, through: :image_instances
  # has_many :media_instances
  # has_many :medias, through: :media_instances

  def render
    fail 'not implemented'
  end

  def path
    fail 'not implemented'
  end
end
