module Content
  extend ActiveSupport::Concern

  include Metadata
  include Slug
  include Taggable

  # has_many :images
  # has_many :medias
end
