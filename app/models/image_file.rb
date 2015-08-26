class ImageFile < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :image

  has_paper_trail
  valhammer

  validates_uniqueness_of :default_image, scope: :image_id,
                                          if: :default_image?
  validates_uniqueness_of :original_image, scope: :image_id,
                                           if: :original_image?

  def path
  end
end
