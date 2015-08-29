class ImageInstance < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :image
  belongs_to :imageable, polymorphic: true

  has_paper_trail
  valhammer
end
