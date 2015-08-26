class Image < ActiveRecord::Base
  include ParentSite
  include Metadata
  include Taggable

  has_many :image_files do
    def default_image
      find_by(default_image: true)
    end

    def original_image
      find_by(original_image: true)
    end
  end

  has_paper_trail
  valhammer
end
