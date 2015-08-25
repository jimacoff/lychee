class Image < ActiveRecord::Base
  include ParentSite
  include Metadata
  include Taggable

  has_many :image_files do
    def find_by_base_image
      find_by(default_image_file: true)
    end
  end

  has_paper_trail
  valhammer
end
