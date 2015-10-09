class ImageInstance < ActiveRecord::Base
  include ParentSite
  include Metadata
  include Taggable

  belongs_to :image
  belongs_to :imageable, polymorphic: true

  has_paper_trail
  valhammer

  delegate :routable?, to: :image
  delegate :enabled?, to: :image

  def name
    self[:name] || image.name
  end

  def description
    self[:description] || image.description
  end
end
