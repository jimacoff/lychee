class ImageFile < ActiveRecord::Base
  include ParentSite
  include Metadata
  include Routable

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

  def srcset_path
    return nil unless path.present?
    return "#{uri_path} #{x_dimension}" if x_dimension

    "#{uri_path} #{width}w"
  end

  def create_default_path
    create_path(parent: default_parent_path, segment: filename)
  end

  def default_parent_path
    if site_images_path
      image_assets_path = Path.find_or_create_by_path(site_images_path)
      image_assets_path.find_or_create_by_path(image.internal_name)
    else
      Path.find_or_create_by_path(image.internal_name)
    end
  end

  private

  def site_images_path
    site.preferences.reserved_uri_path('images')
  end
end
