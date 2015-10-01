class ImageFile < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :image

  has_paper_trail
  valhammer

  validates :default_image,
            uniqueness: { scope: :image_id, if: :default_image? }
  validates :original_image,
            uniqueness: { scope: :image_id, if: :original_image? }

  def filename
    "#{width}.#{height}.#{image.extension}"
  end

  def path
    "#{site.preferences.reserved_paths['images']}" \
    "/#{image.internal_name}/#{filename}"
  end

  def srcset_path
    return "#{path} #{x_dimension}" if x_dimension

    "#{path} #{width}w"
  end
end
