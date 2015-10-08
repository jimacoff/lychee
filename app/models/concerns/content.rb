module Content
  extend ActiveSupport::Concern

  include Metadata
  include Taggable
  include Routable

  included do
    has_many :image_instances, as: :imageable
    has_many :images, through: :image_instances
  end
  # has_many :media_instances
  # has_many :medias, through: :media_instances
end
