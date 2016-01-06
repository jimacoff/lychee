class Image < ActiveRecord::Base
  include ParentSite
  include Metadata
  include Taggable
  include Enablement

  has_many :image_files do
    def default_image
      find_by(default_image: true)
    end

    def original_image
      find_by(original_image: true)
    end

    def srcset
      where(original_image: false)
    end
  end

  has_paper_trail
  valhammer

  validate :references_original_image, unless: :new_record?
  validate :references_default_image, unless: :new_record?

  def references_original_image
    return if image_files.original_image
    errors.add(:original_image, 'not registered')
  end

  def references_default_image
    return if image_files.default_image
    errors.add(:default_image, 'not registered')
  end

  def default_path
    image_files.default_image.uri_path
  end

  def srcset_path
    image_files.eager_load(path: [:self_and_ancestors, :ancestor_hierarchies])
      .srcset.map(&:srcset_path).join(', ')
  end

  def routable?
    image_files.default_image.routable?
  end

  def enabled?
    enabled && image_files.default_image.enabled?
  end
end
