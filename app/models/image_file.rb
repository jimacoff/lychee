class ImageFile < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :image

  has_paper_trail
  valhammer

  def path
  end
end
